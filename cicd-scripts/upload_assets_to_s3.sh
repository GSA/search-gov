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

# S3 Configuration from environment variables
S3_BUCKET="${AWS_S3_BUCKET:-${AWS_BUCKET:-}}"
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
  
  # Sync assets to S3 with appropriate cache headers
  # - Delete files in S3 that don't exist locally (cleanup old assets)
  # - Set appropriate cache headers for fingerprinted assets (1 year)
  # - Set shorter cache for non-fingerprinted assets (1 hour)
  
  # Upload fingerprinted assets with long cache (these have content hashes in filename)
  if aws s3 sync "$source_dir" "s3://${S3_BUCKET}${s3_path}" \
    --region "$AWS_REGION" \
    --exclude "*" \
    --include "*-*.js" \
    --include "*-*.css" \
    --include "*-*.js.gz" \
    --include "*-*.css.gz" \
    --include "*-*.png" \
    --include "*-*.jpg" \
    --include "*-*.jpeg" \
    --include "*-*.gif" \
    --include "*-*.svg" \
    --include "*-*.woff" \
    --include "*-*.woff2" \
    --include "*-*.ttf" \
    --include "*-*.eot" \
    --cache-control "public, max-age=31536000, immutable" \
    --acl public-read \
    --delete; then
    log "Successfully synced fingerprinted assets from $source_dir"
  else
    error "Failed to sync fingerprinted assets from $source_dir"
    return 1
  fi
  
  # Upload non-fingerprinted assets with shorter cache (these are stable filenames)
  # These are created by copy_non_fingerprinted_assets.sh
  if aws s3 sync "$source_dir" "s3://${S3_BUCKET}${s3_path}" \
    --region "$AWS_REGION" \
    --exclude "*-*.*" \
    --exclude ".sprockets-manifest-*.json" \
    --exclude "manifest.json" \
    --cache-control "public, max-age=3600" \
    --acl public-read; then
    log "Successfully synced non-fingerprinted assets from $source_dir"
  else
    error "Failed to sync non-fingerprinted assets from $source_dir"
    return 1
  fi
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
