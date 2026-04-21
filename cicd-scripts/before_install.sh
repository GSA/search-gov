#!/bin/bash
set -euo pipefail

log() {
  echo "[CODEDEPLOY][BEFORE_INSTALL] $*"
}

APP_ROOT="${APP_ROOT:-/home/search/searchgov}"
STAGING_ROOT="${STAGING_ROOT:-/home/search/cicd_temp}"
RELEASES_DIR="${APP_ROOT}/releases"
SHARED_DIR="${APP_ROOT}/shared"

log "Starting BeforeInstall hook"
log "Host: $(hostname) | User: $(whoami)"
log "APP_ROOT=$APP_ROOT"
log "STAGING_ROOT=$STAGING_ROOT"

# Ensure directory structure exists and is writable by deployment user.
mkdir -p "$RELEASES_DIR" "$SHARED_DIR" "$SHARED_DIR/config" "$SHARED_DIR/tmp/pids" "$SHARED_DIR/log"

# Keep a rolling set of release directories to control disk growth.
if [ -d "$RELEASES_DIR" ]; then
  log "Pruning old releases (keeping most recent 5)"
  # NOTE: Avoid `ls "$RELEASES_DIR"/*` with `set -euo pipefail`; it exits non-zero
  # when no releases exist and would fail the whole hook.
  mapfile -t release_dirs < <(find "$RELEASES_DIR" -mindepth 1 -maxdepth 1 -type d -print | sort)
  if [ "${#release_dirs[@]}" -gt 5 ]; then
    printf '%s\n' "${release_dirs[@]}" | head -n -5 | xargs -r rm -rf
  else
    log "No old releases to prune"
  fi
fi

# Ensure logs and pid files exist for service startup.
touch "$SHARED_DIR/log/puma_access.log" "$SHARED_DIR/log/puma_error.log"

# Keep CodeDeploy staging root available and writable for this deployment.
mkdir -p "$STAGING_ROOT"

log "BeforeInstall hook completed"
