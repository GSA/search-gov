#!/bin/bash
set -euo pipefail

if [ -f /home/search/.config/searchgov-codedeploy.env ]; then
  set -a
  # shellcheck disable=SC1090
  source /home/search/.config/searchgov-codedeploy.env
  set +a
fi

log() {
  echo "[CODEDEPLOY][VALIDATE_SERVICE] $*"
}

warn() {
  echo "[CODEDEPLOY][VALIDATE_SERVICE][WARN] $*"
}

error() {
  echo "[CODEDEPLOY][VALIDATE_SERVICE][ERROR] $*" >&2
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

assert_service_active_required() {
  local service_name="$1"

  if ! service_exists "$service_name"; then
    error "Required service unit missing: $service_name"
    exit 1
  fi
  log "Checking required service is active: $service_name"
  if ! systemctl is-active --quiet "$service_name"; then
    error "Required service is not active: $service_name"
    exit 1
  fi
  log "Service is active: $service_name"
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

if [ "${REQUIRE_RESQUE_SERVICES:-false}" = "true" ]; then
  assert_service_active_required "$RESQUE_WORKER_SERVICE"
  assert_service_active_required "$RESQUE_SCHEDULER_SERVICE"
else
  assert_service_active_if_present "$RESQUE_WORKER_SERVICE"
  assert_service_active_if_present "$RESQUE_SCHEDULER_SERVICE"
fi

assert_service_active_if_present "$PUMA_SERVICE"

log "Validating HTTP endpoint: $APP_HEALTHCHECK_URL"
wait_for_http_healthy "$APP_HEALTHCHECK_URL" "${HEALTHCHECK_ATTEMPTS:-12}" "${HEALTHCHECK_SLEEP_SECONDS:-5}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
if [ "${REQUIRE_RESQUE_CWD_CHECK:-false}" = "true" ]; then
  log "Running Resque cwd verification (REQUIRE_RESQUE_CWD_CHECK)"
  bash "$SCRIPT_DIR/verify_resque_cwd.sh"
fi

log "ValidateService hook completed"
