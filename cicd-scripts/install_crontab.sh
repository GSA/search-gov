#!/bin/bash
set -euo pipefail

log() {
  echo "[CODEDEPLOY][AFTER_INSTALL][install_crontab] $*"
}

warn() {
  echo "[CODEDEPLOY][AFTER_INSTALL][install_crontab][WARN] $*"
}

error() {
  echo "[CODEDEPLOY][AFTER_INSTALL][install_crontab][ERROR] $*" >&2
}

is_cron_host() {
  local short_hostname
  short_hostname="$(hostname -s 2>/dev/null || hostname)"

  [[ "$short_hostname" == cron* ]]
}

load_env_key() {
  local env_file="$1"
  local key="$2"
  local line
  local value

  if [ ! -f "$env_file" ]; then
    return 0
  fi

  line="$(grep -E "^${key}=" "$env_file" | tail -n 1 || true)"
  if [ -z "$line" ]; then
    return 0
  fi

  value="${line#*=}"
  case "$value" in
    \"*\") value="${value#\"}"; value="${value%\"}" ;;
    \'*\') value="${value#\'}"; value="${value%\'}" ;;
  esac

  export "${key}=${value}"
}

if [ "${INSTALL_SEARCHGOV_CRONTAB:-auto}" != "true" ] && ! is_cron_host; then
  log "Host is not a cron host; skipping Search.gov crontab install"
  exit 0
fi

SEARCHGOV_ROOT="${SEARCHGOV_ROOT:-/home/search/searchgov}"
CURRENT_PATH="${SEARCHGOV_ROOT}/current"
SHARED_DIR="${SEARCHGOV_ROOT}/shared"
ENV_FILE="${SHARED_DIR}/.env"
CRONTAB_IDENTIFIER="${CRONTAB_IDENTIFIER:-searchgov}"

log "Installing Search.gov crontab"
log "Current path: $CURRENT_PATH"

if [ ! -f "${CURRENT_PATH}/config/schedule.rb" ]; then
  warn "Schedule file not found; skipping: ${CURRENT_PATH}/config/schedule.rb"
  exit 0
fi

for key in DB_USER DB_PASSWORD DB_HOST DB_NAME; do
  load_env_key "$ENV_FILE" "$key"
done

missing_db_keys=()
for key in DB_USER DB_PASSWORD DB_HOST DB_NAME; do
  if [ -z "${!key:-}" ]; then
    missing_db_keys+=("$key")
  fi
done

if [ "${#missing_db_keys[@]}" -gt 0 ]; then
  error "Missing DB env values for whenever command interpolation: ${missing_db_keys[*]}"
  exit 1
fi

export HOME=/home/search
export RBENV_ROOT=/home/search/.rbenv
export PATH="${RBENV_ROOT}/bin:${RBENV_ROOT}/shims:/usr/local/bin:/usr/bin:/bin"
export RAILS_ENV=production
export BUNDLE_WITHOUT=development:test
export BUNDLE_PATH="${SHARED_DIR}/bundle"
export BUNDLE_APP_CONFIG="${SHARED_DIR}/.bundle"
export BUNDLE_DEPLOYMENT=false
export BUNDLE_FROZEN=false

cd "$CURRENT_PATH"

bundle exec whenever \
  --update-crontab "$CRONTAB_IDENTIFIER" \
  --load-file config/schedule.rb \
  --set environment=production \
  --set path="$CURRENT_PATH"

log "Search.gov crontab installed"
