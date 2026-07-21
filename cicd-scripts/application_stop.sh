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
  local unit_name="$1"
  systemctl list-unit-files "${unit_name}.service" --no-legend 2>/dev/null | grep -q . || \
    systemctl list-unit-files "${unit_name}" --no-legend 2>/dev/null | grep -q .
}

resolve_puma_service() {
  if [ -n "${PUMA_SERVICE:-}" ]; then
    echo "$PUMA_SERVICE"
    return 0
  fi

  # Prefer the real, hand-authored "puma" unit (defined in this repo's
  # cicd-scripts, used by the current CodeDeploy-hook-driven deploy path) if
  # it exists. Only fall back to pattern-matching a "puma_search-gov_*" unit
  # for hosts that genuinely have no plain "puma" unit at all -- e.g. a
  # still-Capistrano-managed tier where Capistrano::Puma::Systemd created
  # that name instead. Checking "puma" first avoids matching a stale,
  # leftover Capistrano-era unit (e.g. puma_search-gov_development) on a
  # host that has since moved to the plain "puma" unit, which would
  # otherwise silently stop/validate the wrong service every deploy.
  if service_exists "puma"; then
    echo "puma"
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
    sudo systemctl stop "$service_name"
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
