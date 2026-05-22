#!/bin/bash
set -euo pipefail

REPO="/Users/andy/repos/holdings-org"
SRC="/Users/andy/Library/CloudStorage/GoogleDrive-lexieljzhao@gmail.com/My Drive/Zhao-Family-Holdings/05_ai-mcn/team-distribution.html"
DEST="$REPO/team-distribution.html"
LOG="$REPO/sync.log"

notify_failure() {
  local msg="$1"
  printf '%s ALERT %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$msg" >> "$LOG"
  osascript -e "display notification \"$msg\" with title \"HoldingsOrgSync failed\"" >/dev/null 2>&1 || true
}

{
  printf '%s sync start\n' "$(date '+%Y-%m-%d %H:%M:%S')"

  if [ ! -f "$SRC" ]; then
    notify_failure "source team-distribution.html missing"
    exit 1
  fi

  if [ ! -d "$REPO/.git" ]; then
    notify_failure "holdings-org repo missing .git"
    exit 1
  fi

  cp "$SRC" "$DEST"
  cd "$REPO"

  if git diff --quiet -- team-distribution.html README.md sync.sh; then
    printf '%s no changes\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    exit 0
  fi

  git add team-distribution.html README.md sync.sh
  git commit -m "Sync team distribution page"
  git push origin main
  printf '%s pushed ✓\n' "$(date '+%Y-%m-%d %H:%M:%S')"
} >> "$LOG" 2>&1 || {
  notify_failure "sync.sh exited with failure"
  exit 1
}
