#!/bin/bash
set -euo pipefail

log() {
  echo "[CODEDEPLOY][APPLICATION_STOP] $*"
}

service_exists() {
  local service_name="$1"
  systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}' | grep -Fxq "${service_name}.service" || \
    systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}' | grep -Fxq "$service_name"
}

stop_service_if_present() {
  local service_name="$1"

  if service_exists "$service_name"; then
    log "Stopping service: $service_name"
    systemctl stop "$service_name"
  else
    log "Service not found, skipping: $service_name"
  fi
}

# These defaults are intentionally overridable per environment.
PUMA_SERVICE="${PUMA_SERVICE:-puma}"
RESQUE_WORKER_SERVICE="${RESQUE_WORKER_SERVICE:-resque-worker}"
RESQUE_SCHEDULER_SERVICE="${RESQUE_SCHEDULER_SERVICE:-resque-scheduler}"

log "Starting ApplicationStop hook"
log "Host: $(hostname) | User: $(whoami)"

stop_service_if_present "$PUMA_SERVICE"
stop_service_if_present "$RESQUE_WORKER_SERVICE"
stop_service_if_present "$RESQUE_SCHEDULER_SERVICE"

log "ApplicationStop hook completed"
