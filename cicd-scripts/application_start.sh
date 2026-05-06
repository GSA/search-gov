#!/bin/bash
set -euo pipefail

log() {
  echo "[CODEDEPLOY][APPLICATION_START] $*"
}

warn() {
  echo "[CODEDEPLOY][APPLICATION_START][WARN] $*"
}

error() {
  echo "[CODEDEPLOY][APPLICATION_START][ERROR] $*"
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

restart_or_start_service() {
  local service_name="$1"

  if service_exists "$service_name"; then
    log "Restarting service: $service_name"
    run_systemctl restart "$service_name"
  else
    log "Service not found, skipping: $service_name"
  fi
}

wait_for_http_healthy() {
  local url="$1"
  local attempts="${2:-12}"
  local sleep_seconds="${3:-5}"
  local try=1

  while [ "$try" -le "$attempts" ]; do
    if curl --fail --silent --show-error --max-time 10 "$url" >/dev/null; then
      log "HTTP endpoint became healthy on attempt ${try}/${attempts}: $url"
      return 0
    fi

    if [ "$try" -lt "$attempts" ]; then
      warn "HTTP endpoint not ready yet (attempt ${try}/${attempts}): $url"
      sleep "$sleep_seconds"
    fi

    try=$((try + 1))
  done

  return 1
}

dump_startup_diagnostics() {
  local app_root="$1"
  local current_path="${app_root}/current"

  warn "Collecting startup diagnostics"
  warn "PATH=$PATH"
  warn "pwd=$(pwd)"

  if command -v ss >/dev/null 2>&1; then
    warn "Listening sockets on :3000 (ss)"
    ss -ltnp 2>/dev/null | grep ':3000' || true
  elif command -v netstat >/dev/null 2>&1; then
    warn "Listening sockets on :3000 (netstat)"
    netstat -lntp 2>/dev/null | grep ':3000' || true
  fi

  warn "Running puma-related processes"
  ps -ef | grep -E 'puma|rails server' | grep -v grep || true

  if [ -f "${current_path}/log/puma_error.log" ]; then
    warn "Tail of ${current_path}/log/puma_error.log"
    tail -n 80 "${current_path}/log/puma_error.log" || true
  fi

  if [ -f "${current_path}/log/puma_stdout.log" ]; then
    warn "Tail of ${current_path}/log/puma_stdout.log"
    tail -n 80 "${current_path}/log/puma_stdout.log" || true
  fi

  if [ -f "${current_path}/log/puma_stderr.log" ]; then
    warn "Tail of ${current_path}/log/puma_stderr.log"
    tail -n 80 "${current_path}/log/puma_stderr.log" || true
  fi

  if [ -f "${current_path}/log/production.log" ]; then
    warn "Tail of ${current_path}/log/production.log"
    tail -n 80 "${current_path}/log/production.log" || true
  fi
}

PUMA_SERVICE="$(resolve_puma_service)"
RESQUE_WORKER_SERVICE="${RESQUE_WORKER_SERVICE:-resque-worker}"
RESQUE_SCHEDULER_SERVICE="${RESQUE_SCHEDULER_SERVICE:-resque-scheduler}"
SEARCHGOV_ROOT="${SEARCHGOV_ROOT:-/home/search/searchgov}"
APP_HEALTHCHECK_URL="${APP_HEALTHCHECK_URL:-http://127.0.0.1:3000/}"

log "Starting ApplicationStart hook"
log "Host: $(hostname) | User: $(whoami)"

restart_or_start_service "$PUMA_SERVICE"
restart_or_start_service "$RESQUE_WORKER_SERVICE"
restart_or_start_service "$RESQUE_SCHEDULER_SERVICE"

if service_exists "$PUMA_SERVICE"; then
  if ! wait_for_http_healthy "$APP_HEALTHCHECK_URL" "${HEALTHCHECK_ATTEMPTS:-12}" "${HEALTHCHECK_SLEEP_SECONDS:-5}"; then
    error "ApplicationStart could not bring app online at $APP_HEALTHCHECK_URL"
    dump_startup_diagnostics "$SEARCHGOV_ROOT"
    exit 1
  fi
else
  log "Puma service not present on this host, skipping HTTP health check"
fi

log "ApplicationStart hook completed"
