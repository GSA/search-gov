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

# Link shared files.
# Remove any real log/ and tmp/ dirs first. If they already exist as directories,
# `ln -sfn` creates the symlink *inside* them (e.g. release/log/log -> shared/log),
# which orphans request logs in the release dir instead of shared/log -- the path the
# CloudWatch agent tails. Removing them guarantees release/log -> shared/log directly.
mkdir -p "$RELEASE_DIR/config"
rm -rf "$RELEASE_DIR/log" "$RELEASE_DIR/tmp"
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

# Create shared bundle directories and persist config for systemd
mkdir -p "$SHARED_DIR/bundle" "$SHARED_DIR/.bundle"
cat > "$SHARED_DIR/.bundle/config" <<BUNDLECONF
---
BUNDLE_PATH: "$SHARED_DIR/bundle"
BUNDLE_WITHOUT: "development:test"
BUNDLECONF

# Symlink per-release .bundle to shared config so systemd's bundler
# can find BUNDLE_PATH without needing env vars at runtime
rm -rf "$RELEASE_DIR/.bundle"
ln -sfn "$SHARED_DIR/.bundle" "$RELEASE_DIR/.bundle"

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

# SRCH-6631: Only run database migrations on the main "app" tier. All other
# tiers (crawler, cron, spider, api, proxy, letsencrypt, and their -green
# counterparts) share the same production RDS instance but must NOT run
# migrations independently, since deploying to those tiers could otherwise
# apply schema changes the main app fleet's currently-running release does
# not expect. See: prod_outage_20260710_shared_db_migration_incident.md for
# the incident this guards against.
#
# NOTE: an earlier version of this gate checked $DEPLOYMENT_GROUP_NAME
# (set directly by the CodeDeploy agent, no IMDS/AWS API calls needed).
# That approach breaks once app/crawler/cron are consolidated behind a
# single shared deployment group (dg_searchgov) -- at that point
# DEPLOYMENT_GROUP_NAME is identical for all three tiers and can no longer
# distinguish them. This version instead reads the instance's own
# terraform_module EC2 tag, which is set independently per-instance by
# Terraform at provisioning time and is unaffected by which deployment
# group happens to trigger a given deployment.
#
# Fail-safe: if the tag cannot be resolved for any reason, migrations are
# SKIPPED (never default to running them).
get_terraform_module_tag() {
  local imds_token instance_id tag_value

  imds_token=$(curl -sS --fail --max-time 2 -X PUT \
    "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 300" 2>/dev/null || true)
  if [ -z "$imds_token" ]; then
    warn "Could not retrieve IMDSv2 token; terraform_module tag unknown"
    echo "unknown"
    return
  fi

  instance_id=$(curl -sS --fail --max-time 2 \
    -H "X-aws-ec2-metadata-token: $imds_token" \
    "http://169.254.169.254/latest/meta-data/instance-id" 2>/dev/null || true)

  if [ -z "$instance_id" ]; then
    warn "Could not determine instance-id; terraform_module tag unknown"
    echo "unknown"
    return
  fi

  # Deliberately omit --region: AWS CLI v2 automatically resolves the region
  # via IMDS when no region is set via env var/profile/flag.
  tag_value=$(aws ec2 describe-tags \
    --filters "Name=resource-id,Values=$instance_id" "Name=key,Values=terraform_module" \
    --query "Tags[0].Value" --output text 2>/dev/null || true)

  if [ -z "$tag_value" ] || [ "$tag_value" = "None" ]; then
    warn "terraform_module tag not found on this instance; defaulting to unknown"
    echo "unknown"
    return
  fi

  echo "$tag_value"
}

TERRAFORM_MODULE="$(get_terraform_module_tag)"

# Every branch of this case logs the resolved terraform_module value and
# whether migrations ran, so every pipeline run's log clearly shows which
# tier it deployed to and whether db:migrate executed -- needed for
# troubleshooting/verification once app/crawler/cron share one deployment
# group and are no longer distinguishable by deployment group name alone.
case "$TERRAFORM_MODULE" in
  app | app-green)
    log "Running database migrations (terraform_module=$TERRAFORM_MODULE)"
    RAILS_ENV=production bundle exec rails db:migrate
    ;;
  *)
    log "Skipping database migrations (terraform_module=$TERRAFORM_MODULE) -- not the migration-owning tier"
    ;;
esac

# Atomically promote release
log "Promoting release to current"

TMP_LINK="${APP_ROOT}/.current_tmp"
ln -sfn "$RELEASE_DIR" "$TMP_LINK"
mv -Tf "$TMP_LINK" "$CURRENT_LINK"

NEW_CURRENT=$(readlink -f "$CURRENT_LINK")
log "Current symlink now: $NEW_CURRENT"

log "AfterInstall hook completed"
