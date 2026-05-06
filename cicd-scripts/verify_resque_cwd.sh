#!/bin/bash
set -euo pipefail

log() {
  echo "[CODEDEPLOY][VERIFY_RESQUE_CWD] $*"
}

err() {
  echo "[CODEDEPLOY][VERIFY_RESQUE_CWD][ERROR] $*" >&2
}

ROOT="${SEARCHGOV_ROOT:-/home/search/searchgov}"
CURRENT=$(readlink -f "$ROOT/current" 2>/dev/null || true)
if [[ -z "${CURRENT:-}" || ! -d "$CURRENT" ]]; then
  err "No valid current release at $ROOT/current"
  exit 1
fi

log "Expecting Resque processes cwd under: $CURRENT"

bad=0
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  pid="${line%% *}"
  args="${line#* }"
  [[ "$args" == *resque* ]] || continue
  [[ "$args" == *grep* ]] && continue
  if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
    continue
  fi
  cwd=$(readlink -f "/proc/$pid/cwd" 2>/dev/null || true)
  if [[ -z "$cwd" ]]; then
    continue
  fi
  case "$cwd" in
    "$CURRENT"/*|"$CURRENT")
      ;;
    *)
      err "PID $pid cwd=$cwd not under current release $CURRENT (args=${args:0:120})"
      bad=1
      ;;
  esac
done < <(ps -u search -ww -o pid=,args= 2>/dev/null || true)

if [[ "$bad" -ne 0 ]]; then
  err "One or more Resque processes are running from a stale release path"
  exit 1
fi

log "Resque process working directories look valid"
exit 0
