#!/bin/bash
set -euo pipefail

log() {
  echo "[CODEDEPLOY][VALIDATE_SERVICE] $*"
}

warn() {
  echo "[CODEDEPLOY][VALIDATE_SERVICE][WARN] $*"
}

run_systemctl() {
  if [ "$(id -u)" -eq 0 ]; then
    systemctl "$@"
  else
    sudo -n systemctl "$@"
  fi
}

service_exists() {
  local service_name="$1"
  run_systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}' | grep -Fxq "${service_name}.service" || \
    run_systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}' | grep -Fxq "$service_name"
}

resolve_puma_service() {
  if [ -n "${PUMA_SERVICE:-}" ]; then
    echo "$PUMA_SERVICE"
    return 0
  fi

  local discovered_service
  discovered_service="$(run_systemctl list-unit-files --type=service --no-legend 2>/dev/null \
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

assert_service_active_if_present() {
  local service_name="$1"

  if service_exists "$service_name"; then
    log "Checking service is active: $service_name"
    run_systemctl is-active --quiet "$service_name"
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

assert_puma_serving_current_release() {
  local app_root="$1"
  local expected_current
  local pids

  expected_current="$(readlink -f "${app_root}/current" 2>/dev/null || true)"
  if [ -z "$expected_current" ]; then
    warn "Unable to resolve ${app_root}/current; skipping Puma cwd validation"
    return 0
  fi

  if command -v lsof >/dev/null 2>&1; then
    pids="$(lsof -ti:3000 2>/dev/null || true)"
  else
    pids="$(pgrep -f 'puma.*3000|puma' 2>/dev/null || true)"
  fi

  if [ -z "$pids" ]; then
    warn "No Puma process found on port 3000; HTTP validation will determine service health"
    return 0
  fi

  for pid in $pids; do
    local cwd
    cwd="$(readlink -f "/proc/${pid}/cwd" 2>/dev/null || true)"
    if [ -z "$cwd" ]; then
      warn "Unable to inspect cwd for Puma PID ${pid}; skipping that process"
      continue
    fi

    log "Puma PID ${pid} cwd: ${cwd}"
    if [ "$cwd" != "$expected_current" ]; then
      echo "[CODEDEPLOY][VALIDATE_SERVICE][ERROR] Puma PID ${pid} is serving ${cwd}, expected ${expected_current}" >&2
      return 1
    fi
  done
}

PUMA_SERVICE="$(resolve_puma_service)"
RESQUE_WORKER_SERVICE="${RESQUE_WORKER_SERVICE:-resque-worker}"
RESQUE_SCHEDULER_SERVICE="${RESQUE_SCHEDULER_SERVICE:-resque-scheduler}"
APP_HEALTHCHECK_URL="${APP_HEALTHCHECK_URL:-http://127.0.0.1:3000/}"
SEARCHGOV_ROOT="${SEARCHGOV_ROOT:-/home/search/searchgov}"

log "Starting ValidateService hook"
log "Host: $(hostname) | User: $(whoami)"

assert_service_active_if_present "$PUMA_SERVICE"
assert_service_active_if_present "$RESQUE_WORKER_SERVICE"
assert_service_active_if_present "$RESQUE_SCHEDULER_SERVICE"

log "Validating HTTP endpoint: $APP_HEALTHCHECK_URL"
wait_for_http_healthy "$APP_HEALTHCHECK_URL" "${HEALTHCHECK_ATTEMPTS:-12}" "${HEALTHCHECK_SLEEP_SECONDS:-5}"
assert_puma_serving_current_release "$SEARCHGOV_ROOT"

log "ValidateService hook completed"
