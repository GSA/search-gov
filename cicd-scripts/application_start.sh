#!/bin/bash
set -euo pipefail

log() {
  echo "[CODEDEPLOY][APPLICATION_START] $*"
}

service_exists() {
  local service_name="$1"
  systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}' | grep -Fxq "${service_name}.service" || \
    systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}' | grep -Fxq "$service_name"
}

restart_or_start_service() {
  local service_name="$1"

  if service_exists "$service_name"; then
    log "Restarting service: $service_name"
    systemctl restart "$service_name"
  else
    log "Service not found, skipping: $service_name"
  fi
}

PUMA_SERVICE="${PUMA_SERVICE:-puma}"
RESQUE_WORKER_SERVICE="${RESQUE_WORKER_SERVICE:-resque-worker}"
RESQUE_SCHEDULER_SERVICE="${RESQUE_SCHEDULER_SERVICE:-resque-scheduler}"

log "Starting ApplicationStart hook"
log "Host: $(hostname) | User: $(whoami)"

restart_or_start_service "$PUMA_SERVICE"
restart_or_start_service "$RESQUE_WORKER_SERVICE"
restart_or_start_service "$RESQUE_SCHEDULER_SERVICE"

log "ApplicationStart hook completed"
