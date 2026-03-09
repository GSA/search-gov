#!/bin/bash
set -euo pipefail

log() {
  echo "[CODEDEPLOY][UPLOAD_ASSETS] $*"
}

error() {
  echo "[CODEDEPLOY][UPLOAD_ASSETS][ERROR] $*" >&2
}

# Configuration
SEARCHGOV_ROOT="${SEARCHGOV_ROOT:-/home/search/searchgov}"
CURRENT_PATH="${SEARCHGOV_ROOT}/current"
ASSETS_DIR="${CURRENT_PATH}/public"
SHARED_DIR="${SEARCHGOV_ROOT}/shared"

# Load environment variables from .env file
# Properly handle KEY=VALUE format where values may contain spaces
if [ -f "${SHARED_DIR}/.env" ]; then
  log "Loading environment variables from ${SHARED_DIR}/.env"
  # Read .env splitting only on first '=' to handle values with spaces
  while IFS='=' read -r key value || [ -n "$key" ]; do
    # Skip empty lines and comments
    [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
    # Export the variable (handles values with spaces like cron schedules)
    export "$key=$value"
  done < "${SHARED_DIR}/.env"
else
  error "Environment file not found: ${SHARED_DIR}/.env"
  exit 1
fi

# S3 Configuration from environment variables
# The codebase uses AWS_BUCKET (see config/initializers/s3.rb)
S3_BUCKET="${AWS_BUCKET:-}"
AWS_REGION="${AWS_REGION:-us-east-1}"

log "Starting asset upload to S3"
log "Current path: $CURRENT_PATH"
log "Assets directory: $ASSETS_DIR"

# Validate required environment variables
if [ -z "$S3_BUCKET" ]; then
  error "AWS_S3_BUCKET or AWS_BUCKET environment variable is not set"
  exit 1
fi

if [ -z "${AWS_ACCESS_KEY_ID:-}" ]; then
  error "AWS_ACCESS_KEY_ID environment variable is not set"
  exit 1
fi

if [ -z "${AWS_SECRET_ACCESS_KEY:-}" ]; then
  error "AWS_SECRET_ACCESS_KEY environment variable is not set"
  exit 1
fi

log "S3 Bucket: $S3_BUCKET"
log "AWS Region: $AWS_REGION"

cd "$CURRENT_PATH"

# Check if assets directories exist
if [ ! -d "$ASSETS_DIR/assets" ] && [ ! -d "$ASSETS_DIR/packs" ]; then
  error "Neither public/assets nor public/packs directories found"
  exit 1
fi

# Function to sync assets to S3
sync_to_s3() {
  local source_dir="$1"
  local s3_path="$2"
  
  if [ ! -d "$source_dir" ]; then
    log "Directory not found, skipping: $source_dir"
    return 0
  fi
  
  log "Syncing $source_dir to s3://${S3_BUCKET}${s3_path}"
  
  # Upload ALL assets with long cache by default (most assets are fingerprinted)
  # Using --size-only for faster comparisons since fingerprinted assets are immutable
  if aws s3 sync "$source_dir" "s3://${S3_BUCKET}${s3_path}" \
    --region "$AWS_REGION" \
    --exclude ".sprockets-manifest-*.json" \
    --exclude "manifest.json.br" \
    --cache-control "public, max-age=31536000, immutable" \
    --acl public-read \
    --size-only \
    --delete; then
    log "Successfully synced all assets from $source_dir"
  else
    error "Failed to sync assets from $source_dir"
    return 1
  fi
  
  # Override cache headers for non-fingerprinted assets (stable filenames without hashes)
  # These are created by copy_non_fingerprinted_assets.sh for legacy support
  local non_fingerprinted_files=(
    "sayt_loader_libs.js" "sayt_loader_libs.js.gz"
    "sayt_loader.js" "sayt_loader.js.gz"
    "stats.js" "stats.js.gz"
    "sayt.css" "sayt.css.gz"
    "application.js" "application.js.gz" "application.css" "application.css.gz"
    "runtime.js" "runtime.js.gz"
  )
  
  for file in "${non_fingerprinted_files[@]}"; do
    if [ -f "$source_dir/$file" ]; then
      log "Updating cache headers for non-fingerprinted file: $file"
      aws s3 cp "$source_dir/$file" "s3://${S3_BUCKET}${s3_path}/$file" \
        --region "$AWS_REGION" \
        --cache-control "public, max-age=3600" \
        --acl public-read \
        --metadata-directive REPLACE 2>/dev/null || true
    fi
  done
  
  log "Cache header updates completed for non-fingerprinted assets"
}

# Sync Sprockets assets (public/assets)
if [ -d "$ASSETS_DIR/assets" ]; then
  log "Found public/assets directory"
  sync_to_s3 "$ASSETS_DIR/assets" "/assets"
else
  log "No public/assets directory found, skipping"
fi

# Sync Webpacker assets (public/packs)
if [ -d "$ASSETS_DIR/packs" ]; then
  log "Found public/packs directory"
  sync_to_s3 "$ASSETS_DIR/packs" "/packs"
else
  log "No public/packs directory found, skipping"
fi

log "Asset upload to S3 completed successfully"
log "Assets are now available at: ${ASSET_HOST:-https://${S3_BUCKET}}"
