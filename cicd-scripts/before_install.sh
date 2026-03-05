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
  ls -1dt "$RELEASES_DIR"/* 2>/dev/null | tail -n +6 | xargs -r rm -rf
fi

# Ensure logs and pid files exist for service startup.
touch "$SHARED_DIR/log/puma_access.log" "$SHARED_DIR/log/puma_error.log"

# Keep CodeDeploy staging root available and writable for this deployment.
mkdir -p "$STAGING_ROOT"

log "BeforeInstall hook completed"
