#!/bin/bash
set -euo pipefail

if [ -f /home/search/.config/searchgov-codedeploy.env ]; then
  set -a
  # shellcheck disable=SC1090
  source /home/search/.config/searchgov-codedeploy.env
  set +a
fi

log() {
  echo "[CODEDEPLOY][APPLICATION_START] $*"
}

warn() {
  echo "[CODEDEPLOY][APPLICATION_START][WARN] $*"
}

error() {
  echo "[CODEDEPLOY][APPLICATION_START][ERROR] $*"
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

wait_for_pid_exit() {
  local pid="$1"
  local timeout_seconds="${2:-10}"
  local elapsed=0

  while kill -0 "$pid" >/dev/null 2>&1; do
    if [ "$elapsed" -ge "$timeout_seconds" ]; then
      warn "PID $pid did not exit after ${timeout_seconds}s"
      return 1
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done

  return 0
}

start_puma_fallback() {
  local app_root="$1"
  local current_path="${app_root}/current"
  local puma_pidfile="${PUMA_PIDFILE:-${current_path}/tmp/pids/server.pid}"
  local puma_stdout_log="${PUMA_STDOUT_LOG:-${current_path}/log/puma_stdout.log}"
  local puma_stderr_log="${PUMA_STDERR_LOG:-${current_path}/log/puma_stderr.log}"

  if [ ! -d "$current_path" ]; then
    log "Current release path not found, skipping fallback puma start: $current_path"
    return 0
  fi


  # CodeDeploy hooks run in non-login shells; make rbenv shims available if present.
  if [ -d "/home/search/.rbenv" ]; then
    export RBENV_ROOT="/home/search/.rbenv"
    export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"
    if command -v rbenv >/dev/null 2>&1; then
      eval "$(rbenv init - bash)" || warn "rbenv init failed; continuing"
    fi
  fi

  # Configure shared Bundler environment (same as after_install.sh)
  log "Configuring shared Bundler environment for Puma"
  export BUNDLE_WITHOUT="development:test"
  export BUNDLE_PATH="${app_root}/shared/bundle"
  export BUNDLE_APP_CONFIG="${app_root}/shared/.bundle"
  export BUNDLE_DEPLOYMENT="false"
  export BUNDLE_FROZEN="false"

  # Stop existing Puma process from pidfile (preferred method)
  if [ -f "$puma_pidfile" ]; then
    local existing_pid
    existing_pid="$(cat "$puma_pidfile" 2>/dev/null || true)"
    if [[ -n "$existing_pid" && "$existing_pid" =~ ^[0-9]+$ ]]; then
      if kill -0 "$existing_pid" >/dev/null 2>&1; then
        log "Stopping existing puma process from pidfile: $existing_pid"
        kill "$existing_pid" || true
        wait_for_pid_exit "$existing_pid" 10 || kill -9 "$existing_pid" || true
      fi
    fi
    rm -f "$puma_pidfile"
  else
    # Fallback: If no pidfile exists, check if port 3000 is occupied by Puma
    log "No pidfile found, checking for processes using port 3000..."
    if command -v lsof >/dev/null 2>&1; then
      PORT_3000_PID=$(lsof -ti:3000 2>/dev/null || true)
      if [ -n "$PORT_3000_PID" ]; then
        # Verify it's a Puma process before killing
        if ps -p "$PORT_3000_PID" -o comm= 2>/dev/null | grep -qi puma; then
          log "Found Puma process on port 3000: $PORT_3000_PID"
          log "Killing Puma process on port 3000..."
          kill -TERM "$PORT_3000_PID" 2>/dev/null || true
          sleep 3
          # Force kill if still running
          if lsof -ti:3000 >/dev/null 2>&1; then
            log "Force killing stubborn Puma process on port 3000..."
            kill -KILL $(lsof -ti:3000 2>/dev/null) 2>/dev/null || true
            sleep 1
          fi
          log "Port 3000 cleared"
        else
          warn "Process $PORT_3000_PID on port 3000 is not Puma - leaving it alone"
        fi
      else
        log "Port 3000 is available"
      fi
    else
      warn "lsof command not found, cannot check port 3000"
    fi
  fi

  if ! command -v bundle >/dev/null 2>&1; then
    log "ERROR: bundle command not found in PATH=$PATH"
    return 127
  fi

  cd "$current_path"
  mkdir -p "$(dirname "$puma_pidfile")" "$(dirname "$puma_stdout_log")" "$(dirname "$puma_stderr_log")"

  # NOTE: Puma 6+ can reject `-d` daemon mode depending on config/plugins.
  # Start it in background from the shell and capture logs explicitly.
  log "Starting puma in background (fallback, no systemd service found)"
  RAILS_ENV="${RAILS_ENV:-production}" bundle exec puma -C config/puma.rb >>"$puma_stdout_log" 2>>"$puma_stderr_log" &

  # Brief pause to surface immediate boot failures before health polling starts.
  sleep 2
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

PUMA_SERVICE="${PUMA_SERVICE:-puma}"
RESQUE_WORKER_SERVICE="${RESQUE_WORKER_SERVICE:-resque-worker}"
RESQUE_SCHEDULER_SERVICE="${RESQUE_SCHEDULER_SERVICE:-resque-scheduler}"
SEARCHGOV_ROOT="${SEARCHGOV_ROOT:-/home/search/searchgov}"
APP_HEALTHCHECK_URL="${APP_HEALTHCHECK_URL:-http://127.0.0.1:3000/}"

log "Starting ApplicationStart hook"
log "Host: $(hostname) | User: $(whoami)"

restart_or_start_service "$PUMA_SERVICE"
restart_or_start_service "$RESQUE_WORKER_SERVICE"
restart_or_start_service "$RESQUE_SCHEDULER_SERVICE"

if ! service_exists "$PUMA_SERVICE"; then
  start_puma_fallback "$SEARCHGOV_ROOT"
fi

if ! wait_for_http_healthy "$APP_HEALTHCHECK_URL" "${HEALTHCHECK_ATTEMPTS:-12}" "${HEALTHCHECK_SLEEP_SECONDS:-5}"; then
  error "ApplicationStart could not bring app online at $APP_HEALTHCHECK_URL"
  dump_startup_diagnostics "$SEARCHGOV_ROOT"
  exit 1
fi

log "ApplicationStart hook completed"
