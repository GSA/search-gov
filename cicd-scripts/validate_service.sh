#!/bin/bash
set -euo pipefail

log() {
  echo "[CODEDEPLOY][VALIDATE_SERVICE] $*"
}

service_exists() {
  local service_name="$1"
  systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}' | grep -Fxq "${service_name}.service" || \
    systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}' | grep -Fxq "$service_name"
}

assert_service_active_if_present() {
  local service_name="$1"

  if service_exists "$service_name"; then
    log "Checking service is active: $service_name"
    systemctl is-active --quiet "$service_name"
    log "Service is active: $service_name"
  else
    log "Service not found, skipping active check: $service_name"
  fi
}

PUMA_SERVICE="${PUMA_SERVICE:-puma}"
RESQUE_WORKER_SERVICE="${RESQUE_WORKER_SERVICE:-resque-worker}"
RESQUE_SCHEDULER_SERVICE="${RESQUE_SCHEDULER_SERVICE:-resque-scheduler}"
APP_HEALTHCHECK_URL="${APP_HEALTHCHECK_URL:-http://127.0.0.1:3000/}"

log "Starting ValidateService hook"
log "Host: $(hostname) | User: $(whoami)"

assert_service_active_if_present "$PUMA_SERVICE"
assert_service_active_if_present "$RESQUE_WORKER_SERVICE"
assert_service_active_if_present "$RESQUE_SCHEDULER_SERVICE"

log "Validating HTTP endpoint: $APP_HEALTHCHECK_URL"
curl --fail --silent --show-error --max-time 10 "$APP_HEALTHCHECK_URL" >/dev/null
log "HTTP health check passed"

log "ValidateService hook completed"
