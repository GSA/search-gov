#!/bin/bash
set -euo pipefail

log() {
  echo "[CODEDEPLOY][UPLOAD_ASSETS] $*"
}

warn() {
  echo "[CODEDEPLOY][UPLOAD_ASSETS][WARN] $*"
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
    # Only export valid shell variable names (start with letter/underscore, contain alphanumeric/_)
    if [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
      export "$key=$value"
    fi
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
  log "No assets directories found - skipping upload (this is normal for non-app servers like cron/crawl)"
  log "Asset upload not applicable for this server type"
  exit 0
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
  # Using --size-only for faster comparisons since fingerprinted assets are immutable.
  #
  # Do not use --delete here. CodeDeploy can run this hook on multiple hosts in
  # the same deployment group, and existing hosts may still be serving pages that
  # reference a previous fingerprinted pack. Deleting "old" keys can break those
  # pages with CloudFront/S3 403s before the whole fleet has converged.
  if aws s3 sync "$source_dir" "s3://${S3_BUCKET}${s3_path}" \
    --region "$AWS_REGION" \
    --exclude ".sprockets-manifest-*.json" \
    --exclude "manifest.json.br" \
    --cache-control "public, max-age=31536000, immutable" \
    --acl public-read \
    --size-only; then
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

manifest_pack_keys() {
  local manifest_file="$1"

  ruby -rjson -ruri -e '
    manifest_path = ARGV.fetch(0)
    manifest = JSON.parse(File.read(manifest_path))
    keys = []

    walker = lambda do |value|
      case value
      when Hash
        value.each_value { |nested| walker.call(nested) }
      when Array
        value.each { |nested| walker.call(nested) }
      when String
        path = begin
          URI(value).path
        rescue URI::InvalidURIError
          value
        end
        path = path.sub(%r{\A/}, "")
        keys << path if path.start_with?("packs/")
      end
    end

    walker.call(manifest)
    puts keys.uniq.sort
  ' "$manifest_file"
}

verify_pack_manifest_uploaded() {
  local manifest_file="${ASSETS_DIR}/packs/manifest.json"
  local missing_count=0

  if [ ! -f "$manifest_file" ]; then
    warn "Webpacker manifest not found, skipping pack upload verification: $manifest_file"
    return 0
  fi

  log "Verifying S3 objects referenced by $manifest_file"

  while IFS= read -r key; do
    [ -n "$key" ] || continue

    if aws s3api head-object \
      --bucket "$S3_BUCKET" \
      --key "$key" \
      --region "$AWS_REGION" >/dev/null 2>&1; then
      log "Verified s3://${S3_BUCKET}/${key}"
    else
      error "Missing manifest-referenced asset in S3: s3://${S3_BUCKET}/${key}"
      missing_count=$((missing_count + 1))
    fi
  done < <(manifest_pack_keys "$manifest_file")

  if [ "$missing_count" -gt 0 ]; then
    error "Asset upload verification failed; ${missing_count} manifest-referenced pack object(s) are missing from S3"
    return 1
  fi

  log "All manifest-referenced Webpacker assets are present in S3"
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
  verify_pack_manifest_uploaded
else
  log "No public/packs directory found, skipping"
fi

log "Asset upload to S3 completed successfully"
log "Assets are now available at: ${ASSET_HOST:-https://${S3_BUCKET}}"
