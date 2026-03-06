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

log "Starting AfterInstall hook"
log "Host: $(hostname) | User: $(whoami)"
log "Release dir: $RELEASE_DIR"

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

# Install gems (without --deployment flag for EC2 deployment)
log "Running bundle install"
bundle install --jobs 4 --retry 3 --without development test

# Ensure git gem dependencies are properly checked out
log "Verifying gem dependencies including git gems"
bundle check || bundle install --jobs 4 --retry 3 --without development test

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

# Precompile assets (JavaScript, CSS, images including favicon.ico)
# Use dummy SECRET_KEY_BASE like Dockerfile does
log "Precompiling assets for production"
SECRET_KEY_BASE=placeholder RAILS_ENV=production ./bin/rails assets:precompile

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
