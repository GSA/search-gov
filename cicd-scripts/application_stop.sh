#!/bin/bash
set -euo pipefail

if [ -f /home/search/.config/searchgov-codedeploy.env ]; then
  set -a
  # shellcheck disable=SC1090
  source /home/search/.config/searchgov-codedeploy.env
  set +a
fi

log() {
  echo "[CODEDEPLOY][APPLICATION_STOP] $*"
}

error() {
  echo "[CODEDEPLOY][APPLICATION_STOP][ERROR] $*" >&2
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

if [ "${REQUIRE_RESQUE_SERVICES:-false}" = "true" ]; then
  for required in "$RESQUE_WORKER_SERVICE" "$RESQUE_SCHEDULER_SERVICE"; do
    if ! service_exists "$required"; then
      error "REQUIRE_RESQUE_SERVICES is true but unit not installed: $required (run crawl Ansible resque_systemd role)"
      exit 1
    fi
  done
fi

stop_service_if_present "$PUMA_SERVICE"
stop_service_if_present "$RESQUE_WORKER_SERVICE"
stop_service_if_present "$RESQUE_SCHEDULER_SERVICE"

if [ "${REQUIRE_RESQUE_SERVICES:-false}" = "true" ] && [ "${SKIP_ORPHAN_RESQUE_SIGTERM:-false}" != "true" ]; then
  log "Sending SIGTERM to leftover search-user Resque processes (non-systemd orphans)"
  pkill -u search -TERM -f '[r]esque-' || true
  sleep 3
  pkill -u search -KILL -f '[r]esque-' || true
fi

log "ApplicationStop hook completed"
