#!/bin/bash
set -euo pipefail

log() {
  echo "[CODEDEPLOY][AFTER_INSTALL] $*"
}

warn() {
  echo "[CODEDEPLOY][AFTER_INSTALL][WARN] $*"
}

APP_ROOT="${APP_ROOT:-/home/search/searchgov}"
STAGING_ROOT="${STAGING_ROOT:-/home/search/cicd_temp}"
RELEASES_DIR="${APP_ROOT}/releases"
SHARED_DIR="${APP_ROOT}/shared"
CURRENT_LINK="${APP_ROOT}/current"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"
RELEASE_DIR="${RELEASES_DIR}/${TIMESTAMP}"

# ERR trap to clean up failed releases
cleanup_on_error() {
  local exit_code=$?
  warn "Deployment failed with exit code $exit_code"
  warn "Cleaning up incomplete release: $RELEASE_DIR"
  
  if [ -d "$RELEASE_DIR" ]; then
    rm -rf "$RELEASE_DIR"
    log "Removed failed release directory"
  fi
  
  exit $exit_code
}

trap cleanup_on_error ERR

log "Starting AfterInstall hook"
log "Release dir: $RELEASE_DIR"

# Log current symlink state
if [ -L "$CURRENT_LINK" ]; then
  CURRENT_TARGET=$(readlink -f "$CURRENT_LINK" || echo "unknown")
  log "Current symlink: $CURRENT_TARGET"
fi

# Setup rbenv
if [ -d "/home/search/.rbenv" ]; then
  export RBENV_ROOT="/home/search/.rbenv"
  export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"
  eval "$(rbenv init - bash)" 2>/dev/null || true
fi

mkdir -p "$RELEASE_DIR"

# Copy staged artifact
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete \
    --exclude '.git' \
    --exclude 'log/*' \
    --exclude 'tmp/*' \
    "$STAGING_ROOT/" "$RELEASE_DIR/"
else
  (cd "$STAGING_ROOT" && tar --exclude='.git' --exclude='log' --exclude='tmp' -cf - .) | \
  (cd "$RELEASE_DIR" && tar -xf -)
fi

# Link shared files
mkdir -p "$RELEASE_DIR/config" "$RELEASE_DIR/tmp" "$RELEASE_DIR/log"
ln -sfn "$SHARED_DIR/.env" "$RELEASE_DIR/.env"
ln -sfn "$SHARED_DIR/config/logindotgov.pem" "$RELEASE_DIR/config/logindotgov.pem"
ln -sfn "$SHARED_DIR/log" "$RELEASE_DIR/log"
ln -sfn "$SHARED_DIR/tmp" "$RELEASE_DIR/tmp"

cd "$RELEASE_DIR"

if ! command -v bundle >/dev/null 2>&1; then
  log "ERROR: bundle command not found"
  exit 127
fi

# Configure shared Bundler environment
export BUNDLE_WITHOUT="development:test"
export BUNDLE_PATH="$SHARED_DIR/bundle"
export BUNDLE_APP_CONFIG="$SHARED_DIR/.bundle"
export BUNDLE_DEPLOYMENT="false"
export BUNDLE_FROZEN="false"

log "Bundler config: without=$BUNDLE_WITHOUT, path=$BUNDLE_PATH"

# Create shared bundle directories
mkdir -p "$SHARED_DIR/bundle" "$SHARED_DIR/.bundle"

# Remove per-release bundle config
rm -rf "$RELEASE_DIR/.bundle"

# Optionally clean git gem cache
if [ "${CLEAN_BUNDLER_GIT_CACHE:-false}" = "true" ]; then
  log "Cleaning Bundler git cache"
  rm -rf "$SHARED_DIR/bundle/ruby/"*/cache/bundler/git/* || true
  rm -rf "$SHARED_DIR/bundle/ruby/"*/bundler/gems/* || true
fi

# Install gems
log "Installing gems"
bundle install --jobs 4 --retry 3

# Verify critical git gem
log "Verifying omniauth_login_dot_gov gem"
bundle info omniauth_login_dot_gov

# Precompile bootsnap cache
log "Precompiling bootsnap cache"
bundle exec bootsnap precompile --gemfile || true
bundle exec bootsnap precompile app/ lib/ || true

# Install JavaScript dependencies
if command -v yarn >/dev/null 2>&1; then
  log "Installing JavaScript dependencies"
  yarn install --frozen-lockfile
fi

# Precompile assets
log "Precompiling assets"
SECRET_KEY_BASE=placeholder RAILS_ENV=production ./bin/rails assets:precompile

# Optional migrations
if [ "${RUN_DB_MIGRATIONS:-false}" = "true" ]; then
  log "Running database migrations"
  RAILS_ENV=production bundle exec rails db:migrate
fi

# Atomically promote release
log "Promoting release to current"
TMP_LINK="${APP_ROOT}/.current_tmp"
ln -sfn "$RELEASE_DIR" "$TMP_LINK"
mv -Tf "$TMP_LINK" "$CURRENT_LINK"

NEW_CURRENT=$(readlink -f "$CURRENT_LINK")
log "Current symlink now: $NEW_CURRENT"

log "AfterInstall hook completed"
