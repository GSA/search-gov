#!/bin/bash
set -euo pipefail

log() {
  echo "[CODEDEPLOY][VALIDATE_SERVICE] $*"
}

warn() {
  echo "[CODEDEPLOY][VALIDATE_SERVICE][WARN] $*"
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

wait_for_http_healthy() {
  local url="$1"
  local attempts="${2:-12}"
  local sleep_seconds="${3:-5}"
  local try=1

  while [ "$try" -le "$attempts" ]; do
    if curl --fail --silent --show-error --max-time 10 "$url" >/dev/null; then
      log "HTTP health check passed on attempt ${try}/${attempts}"
      return 0
    fi

    if [ "$try" -lt "$attempts" ]; then
      warn "HTTP endpoint not ready (attempt ${try}/${attempts}); retrying in ${sleep_seconds}s"
      sleep "$sleep_seconds"
    fi

    try=$((try + 1))
  done

  return 1
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
wait_for_http_healthy "$APP_HEALTHCHECK_URL" "${HEALTHCHECK_ATTEMPTS:-12}" "${HEALTHCHECK_SLEEP_SECONDS:-5}"

log "ValidateService hook completed"
