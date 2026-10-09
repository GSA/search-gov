#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=lib/tier_gate.sh
source "$SCRIPT_DIR/lib/tier_gate.sh"

log() {
  echo "[CODEDEPLOY][UPLOAD_ASSETS] $*"
}

error() {
  echo "[CODEDEPLOY][UPLOAD_ASSETS][ERROR] $*" >&2
}

warn() {
  echo "[CODEDEPLOY][UPLOAD_ASSETS][WARN] $*" >&2
}

# Interim asset policy: production will use the app as the primary asset
# origin, with S3 as a backup for older files after the routing change.
# Its CodeDeploy stage precedes Capistrano, so
# uploading here cannot publish the new Capistrano build. Never upload
# from crawler/cron; only dev/staging app hosts may write to S3.
resolve_deployment_tags
case "$ENVIRONMENT:$TERRAFORM_MODULE" in
  dev:app|dev:app-green|staging:app|staging:app-green)
    log "DECISION=UPLOAD environment=$ENVIRONMENT tier=$TERRAFORM_MODULE fleet=${FLEET:-none} reason=app_tier"
    ;;
  production:app|production:app-green)
    log "DECISION=SKIP environment=$ENVIRONMENT tier=$TERRAFORM_MODULE fleet=${FLEET:-none} reason=production_upload_disabled_until_app_cutover"
    log "RESULT=SKIPPED no_S3_calls=true"
    exit 0
    ;;
  *)
    log "DECISION=SKIP environment=$ENVIRONMENT tier=$TERRAFORM_MODULE fleet=${FLEET:-none} reason=not_app_tier"
    log "RESULT=SKIPPED no_S3_calls=true"
    exit 0
    ;;
esac

# Configuration
SEARCHGOV_ROOT="${SEARCHGOV_ROOT:-/home/search/searchgov}"

CURRENT_PATH="${SEARCHGOV_ROOT}/current"
ASSETS_DIR="${CURRENT_PATH}/public"
SHARED_DIR="${SEARCHGOV_ROOT}/shared"

# Load environment variables from .env file
# Properly handle KEY=VALUE format where values may contain spaces
if [ -f "${SHARED_DIR}/.env" ]; then
  log "Reading asset configuration from shared .env (without sourcing it)"
  # Read .env splitting only on first '=' to handle values with spaces
  while IFS='=' read -r key value || [ -n "$key" ]; do
    # Skip empty lines and comments
    [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
    # Only export valid shell variable names (start with letter/underscore, contain alphanumeric/_)
    if [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
      export "$key=$value"
    fi
  done < "${SHARED_DIR}/.env"
else
  error "RESULT=FAILED reason=missing_env_file environment=$ENVIRONMENT tier=$TERRAFORM_MODULE"
  exit 1
fi

# S3 Configuration from environment variables
# The codebase uses AWS_BUCKET (see config/initializers/s3.rb)
S3_BUCKET="${AWS_BUCKET:-}"
AWS_REGION="${AWS_REGION:-us-east-1}"

# Validate required environment variables
if [ -z "$S3_BUCKET" ]; then
  error "RESULT=FAILED reason=missing_bucket environment=$ENVIRONMENT tier=$TERRAFORM_MODULE"
  exit 1
fi

# AWS CLI uses static or instance-role credentials as available.

log "SOURCE_CHECK_STARTED environment=$ENVIRONMENT tier=$TERRAFORM_MODULE fleet=${FLEET:-none} region=$AWS_REGION mode=additive"

if ! cd "$CURRENT_PATH"; then
  error "RESULT=FAILED reason=current_release_unavailable environment=$ENVIRONMENT tier=$TERRAFORM_MODULE"
  exit 1
fi

if [ ! -d "$ASSETS_DIR/assets" ] && [ ! -d "$ASSETS_DIR/packs" ]; then
  warn "RESULT=WARNING reason=no_asset_directories environment=$ENVIRONMENT tier=$TERRAFORM_MODULE note=app_host_uploaded_nothing"
  exit 0
fi

stable_refresh_failures=0
missing_prefixes=0
log "UPLOAD_STARTED environment=$ENVIRONMENT tier=$TERRAFORM_MODULE mode=additive note=source_directory_checks_complete"

# Function to sync assets to S3
sync_to_s3() {
  local source_dir="$1"
  local s3_path="$2"

  if [ ! -d "$source_dir" ]; then
    log "SYNC_RESULT=SKIPPED prefix=$s3_path reason=source_directory_missing"
    missing_prefixes=$((missing_prefixes + 1))
    return 0
  fi

  log "SYNC_STARTED prefix=$s3_path comparison=size_only delete=false"
  # Upload ALL assets with long cache by default (most assets are fingerprinted).
  # Additive sync keeps older fingerprints referenced by pages served earlier.
  if aws s3 sync "$source_dir" "s3://${S3_BUCKET}${s3_path}" \
    --region "$AWS_REGION" \
    --exclude ".sprockets-manifest-*.json" \
    --exclude "manifest.json.br" \
    --cache-control "public, max-age=31536000, immutable" \
    --size-only; then
    log "SYNC_RESULT=SUCCESS prefix=$s3_path note=sync_completed_existing_same_size_objects_may_be_skipped"
  else
    error "SYNC_RESULT=FAILED prefix=$s3_path reason=aws_sync_failed"
    error "RESULT=FAILED environment=$ENVIRONMENT tier=$TERRAFORM_MODULE reason=aws_sync_failed prefix=$s3_path"
    return 1
  fi

  # Override cache headers for non-fingerprinted assets (stable filenames).
  local non_fingerprinted_files=(
    "sayt_loader_libs.js" "sayt_loader_libs.js.gz"
    "sayt_loader.js" "sayt_loader.js.gz"
    "stats.js" "stats.js.gz"
    "sayt.css" "sayt.css.gz"
    "application.js" "application.js.gz" "application.css" "application.css.gz"
    "runtime.js" "runtime.js.gz"
  )

  local file refreshed=0
  for file in "${non_fingerprinted_files[@]}"; do
    if [ -f "$source_dir/$file" ]; then
      log "STABLE_ASSET_REFRESH_STARTED prefix=$s3_path file=$file"
      if aws s3 cp "$source_dir/$file" "s3://${S3_BUCKET}${s3_path}/$file" \
        --region "$AWS_REGION" \
        --cache-control "public, max-age=3600" \
        --metadata-directive REPLACE 2>/dev/null; then
        refreshed=$((refreshed + 1))
      else
        warn "STABLE_ASSET_REFRESH_RESULT=WARNING prefix=$s3_path file=$file reason=aws_cp_failed"
        stable_refresh_failures=$((stable_refresh_failures + 1))
      fi
    fi
  done

  log "STABLE_ASSET_REFRESH_RESULT=COMPLETE prefix=$s3_path refreshed=$refreshed"
}

sync_to_s3 "$ASSETS_DIR/assets" "/assets"
sync_to_s3 "$ASSETS_DIR/packs" "/packs"

if [ "$stable_refresh_failures" -gt 0 ]; then
  log "RESULT=WARNING environment=$ENVIRONMENT tier=$TERRAFORM_MODULE stable_refresh_failures=$stable_refresh_failures missing_prefixes=$missing_prefixes note=sync_succeeded_but_upload_incomplete"
elif [ "$missing_prefixes" -gt 0 ]; then
  log "RESULT=WARNING environment=$ENVIRONMENT tier=$TERRAFORM_MODULE missing_prefixes=$missing_prefixes note=source_directory_missing"
else
  log "RESULT=SUCCESS environment=$ENVIRONMENT tier=$TERRAFORM_MODULE note=s3_sync_completed_cdn_delivery_not_verified"
fi
