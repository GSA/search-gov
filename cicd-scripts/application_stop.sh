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

resolve_puma_service() {
  if [ -n "${PUMA_SERVICE:-}" ]; then
    echo "$PUMA_SERVICE"
    return 0
  fi

  local discovered_service
  discovered_service="$(systemctl list-unit-files --type=service --no-legend 2>/dev/null \
    | awk '{print $1}' \
    | sed 's/\.service$//' \
    | grep -E '^puma_search-gov_' \
    | head -n 1 || true)"

  if [ -n "$discovered_service" ]; then
    echo "$discovered_service"
  else
    echo "puma"
  fi
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
PUMA_SERVICE="$(resolve_puma_service)"
RESQUE_WORKER_SERVICE="${RESQUE_WORKER_SERVICE:-resque-worker}"
RESQUE_SCHEDULER_SERVICE="${RESQUE_SCHEDULER_SERVICE:-resque-scheduler}"

log "Starting ApplicationStop hook"
log "Host: $(hostname) | User: $(whoami)"

stop_service_if_present "$PUMA_SERVICE"
stop_service_if_present "$RESQUE_WORKER_SERVICE"
stop_service_if_present "$RESQUE_SCHEDULER_SERVICE"

log "ApplicationStop hook completed"
