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
  
  # Remove the failed release directory
  if [ -d "$RELEASE_DIR" ]; then
    rm -rf "$RELEASE_DIR"
    log "Removed failed release directory"
  fi
  
  exit $exit_code
}

trap cleanup_on_error ERR

log "Starting AfterInstall hook"
log "Host: $(hostname) | User: $(whoami)"
log "Release dir: $RELEASE_DIR"

# Log current symlink state
if [ -L "$CURRENT_LINK" ]; then
  CURRENT_TARGET=$(readlink -f "$CURRENT_LINK" || echo "unknown")
  log "Current symlink points to: $CURRENT_TARGET"
else
  log "Current symlink does not exist yet"
fi

# CodeDeploy hooks may run in a non-login shell where rbenv shims are not on PATH.
# Add common rbenv paths so `bundle` is discoverable when installed for the deploy user.
if [ -d "/home/search/.rbenv" ]; then
  export RBENV_ROOT="/home/search/.rbenv"
  export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"
  if command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init - bash)" || warn "rbenv init failed; continuing with PATH-based lookup"
  fi
fi

mkdir -p "$RELEASE_DIR"

# Copy staged artifact into a timestamped release directory.
if command -v rsync >/dev/null 2>&1; then
  log "Using rsync to copy staged artifact"
  rsync -a --delete \
    --exclude '.git' \
    --exclude 'log/*' \
    --exclude 'tmp/*' \
    "$STAGING_ROOT/" "$RELEASE_DIR/"
else
  log "rsync not found; using tar fallback to copy staged artifact"
  (
    cd "$STAGING_ROOT"
    tar --exclude='.git' --exclude='log' --exclude='tmp' -cf - .
  ) | (
    cd "$RELEASE_DIR"
    tar -xf -
  )
fi

# Link shared runtime files expected by the Rails app.
mkdir -p "$RELEASE_DIR/config" "$RELEASE_DIR/tmp" "$RELEASE_DIR/log"
ln -sfn "$SHARED_DIR/.env" "$RELEASE_DIR/.env"
ln -sfn "$SHARED_DIR/config/logindotgov.pem" "$RELEASE_DIR/config/logindotgov.pem"
ln -sfn "$SHARED_DIR/log" "$RELEASE_DIR/log"
ln -sfn "$SHARED_DIR/tmp" "$RELEASE_DIR/tmp"

cd "$RELEASE_DIR"

log "Installing gems on target host"
if ! command -v bundle >/dev/null 2>&1; then
  log "ERROR: bundle command not found in PATH=$PATH"
  log "ERROR: Ensure Ruby/Bundler are installed on hosts (via Ansible) or pre-bake in AMI"
  exit 127
fi

# Configure shared Bundler environment using environment variables
log "Configuring shared Bundler environment"
export BUNDLE_WITHOUT="development:test"
export BUNDLE_PATH="$SHARED_DIR/bundle"
export BUNDLE_APP_CONFIG="$SHARED_DIR/.bundle"
export BUNDLE_DEPLOYMENT="false"
export BUNDLE_FROZEN="false"

log "Bundler configuration:"
log "  BUNDLE_WITHOUT=$BUNDLE_WITHOUT"
log "  BUNDLE_PATH=$BUNDLE_PATH"
log "  BUNDLE_APP_CONFIG=$BUNDLE_APP_CONFIG"
log "  BUNDLE_DEPLOYMENT=$BUNDLE_DEPLOYMENT"
log "  BUNDLE_FROZEN=$BUNDLE_FROZEN"

# Create shared bundle directories if missing
log "Ensuring shared bundle directories exist"
mkdir -p "$SHARED_DIR/bundle" "$SHARED_DIR/.bundle"

# Remove per-release .bundle directory to avoid config conflicts
log "Removing per-release .bundle directory"
rm -rf "$RELEASE_DIR/.bundle"

# Optionally clean Bundler git cache to force fresh checkout of git gems
if [ "${CLEAN_BUNDLER_GIT_CACHE:-false}" = "true" ]; then
  log "Cleaning Bundler git cache for fresh gem checkouts"
  rm -rf "$SHARED_DIR/bundle/ruby/"*/cache/bundler/git/* || true
  rm -rf "$SHARED_DIR/bundle/ruby/"*/bundler/gems/* || true
else
  log "Skipping Bundler git cache cleanup (CLEAN_BUNDLER_GIT_CACHE != true)"
fi

# Log bundle environment for diagnostics
log "Bundle environment before install:"
bundle env || true

# Run one authoritative bundle install
log "Running bundle install"
bundle install --jobs 4 --retry 3

# Verify bundle state
log "Verifying bundle installation"
bundle check

# Verify critical git gem is available
log "Verifying omniauth_login_dot_gov gem"
bundle info omniauth_login_dot_gov

# Log bundle config after install
log "Bundle configuration after install:"
bundle config || true

# Precompile bootsnap cache for faster boot times
log "Precompiling bootsnap cache"
bundle exec bootsnap precompile --gemfile || warn "Bootsnap gemfile precompile failed or not available"
bundle exec bootsnap precompile app/ lib/ || warn "Bootsnap app/lib precompile failed or not available"

# Install JavaScript dependencies (required for webpack/webpacker asset compilation)
log "Installing JavaScript dependencies with yarn"
if command -v yarn >/dev/null 2>&1; then
  yarn install --frozen-lockfile
else
  warn "yarn command not found - JavaScript dependencies may not be installed"
  warn "Asset compilation may fail if JavaScript dependencies are required"
fi

# Verify git gem one more time before asset compilation
log "Final verification of omniauth_login_dot_gov before asset compilation"
bundle info omniauth_login_dot_gov

# Precompile assets using bundle exec for consistent environment
log "Precompiling assets for production"
RAILS_ENV=production SECRET_KEY_BASE=placeholder bundle exec rails assets:precompile

# Optional migration hook: set RUN_DB_MIGRATIONS=true in environment to enable.
if [ "${RUN_DB_MIGRATIONS:-false}" = "true" ]; then
  log "Running database migrations"
  RAILS_ENV=production bundle exec rails db:migrate
else
  log "Skipping database migrations (RUN_DB_MIGRATIONS != true)"
fi

# Atomically promote this release (only if we got here without errors)
log "Promoting release to current"
TMP_LINK="${APP_ROOT}/.current_tmp"
ln -sfn "$RELEASE_DIR" "$TMP_LINK"
mv -Tf "$TMP_LINK" "$CURRENT_LINK"

# Log new symlink state
NEW_CURRENT_TARGET=$(readlink -f "$CURRENT_LINK")
log "Current symlink now points to: $NEW_CURRENT_TARGET"

log "AfterInstall hook completed successfully"
