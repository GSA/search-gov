#!/bin/bash
set -euo pipefail

log() {
  echo "[CODEDEPLOY][AFTER_INSTALL] $*"
}

APP_ROOT="${APP_ROOT:-/home/search/searchgov}"
STAGING_ROOT="${STAGING_ROOT:-/home/search/cicd_temp}"
RELEASES_DIR="${APP_ROOT}/releases"
SHARED_DIR="${APP_ROOT}/shared"
CURRENT_LINK="${APP_ROOT}/current"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"
RELEASE_DIR="${RELEASES_DIR}/${TIMESTAMP}"

log "Starting AfterInstall hook"
log "Host: $(hostname) | User: $(whoami)"
log "Release dir: $RELEASE_DIR"

mkdir -p "$RELEASE_DIR"

# Copy staged artifact into a timestamped release directory.
rsync -a --delete \
  --exclude '.git' \
  --exclude 'log/*' \
  --exclude 'tmp/*' \
  "$STAGING_ROOT/" "$RELEASE_DIR/"

# Link shared runtime files expected by the Rails app.
mkdir -p "$RELEASE_DIR/config" "$RELEASE_DIR/tmp" "$RELEASE_DIR/log"
ln -sfn "$SHARED_DIR/.env" "$RELEASE_DIR/.env"
ln -sfn "$SHARED_DIR/config/logindotgov.pem" "$RELEASE_DIR/config/logindotgov.pem"
ln -sfn "$SHARED_DIR/log" "$RELEASE_DIR/log"
ln -sfn "$SHARED_DIR/tmp" "$RELEASE_DIR/tmp"

cd "$RELEASE_DIR"

log "Installing gems on target host"
bundle install --jobs 4 --retry 3 --without development test

# Optional migration hook: set RUN_DB_MIGRATIONS=true in environment to enable.
if [ "${RUN_DB_MIGRATIONS:-false}" = "true" ]; then
  log "Running database migrations"
  bundle exec rails db:migrate RAILS_ENV=production
else
  log "Skipping database migrations (RUN_DB_MIGRATIONS != true)"
fi

# Atomically promote this release.
ln -sfn "$RELEASE_DIR" "$CURRENT_LINK"

log "AfterInstall hook completed"
