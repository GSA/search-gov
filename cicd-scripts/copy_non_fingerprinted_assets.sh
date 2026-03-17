#!/bin/bash
set -euo pipefail

log() {
  echo "[CODEDEPLOY][AFTER_INSTALL][copy_non_fingerprinted_assets] $*"
}

SEARCHGOV_ROOT="${SEARCHGOV_ROOT:-/home/search/searchgov}"
CURRENT_PATH="${SEARCHGOV_ROOT}/current"

cd "$CURRENT_PATH"

copy_assets_in_dir() {
  local target_dir="$1"

  if [ ! -d "$target_dir" ]; then
    log "Directory not found, skipping: $target_dir"
    return 0
  fi

  # We intentionally generate stable non-fingerprinted names for clients that
  # still reference legacy file names.
  while IFS= read -r file; do
    cp "$file" "${file%%-*}.${file##*.}"
  done < <(find "$target_dir" -type f \( -name "*-*.js" -o -name "*-*.css" -o -name "*-*.js.gz" -o -name "*-*.css.gz" \))
}

copy_assets_in_dir "public/packs"
copy_assets_in_dir "public/assets"

log "Completed successfully"
