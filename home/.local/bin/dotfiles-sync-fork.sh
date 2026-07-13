#!/usr/bin/env bash
# dotfiles-sync-fork.sh - weekly: rebase local main onto origin/main, push to fork.
#
# Run by the home-manager launchd agent (dotfiles-sync-fork) every Sunday at
# 16:00 local. On any rebase conflict it aborts and notifies instead of pushing,
# so a broken tree is never force-pushed. Safe to run by hand; idempotent when
# already in sync.
set -uo pipefail

# launchd gives a minimal PATH and doesn't source shell profiles.
export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"

REPO="/Users/bytedance/github/dotfiles"
BRANCH="main"
LOG="$HOME/Library/Logs/dotfiles-sync-fork.log"

mkdir -p "$(dirname "$LOG")"
exec >>"$LOG" 2>&1
echo "===== $(date '+%Y-%m-%d %H:%M:%S') : sync-fork start ====="

notify() { osascript -e "display notification \"$1\" with title \"dotfiles sync-fork\"" 2>/dev/null || true; }
fail()   { echo "ERROR: $1"; notify "$1"; exit 1; }

cd "$REPO" || fail "repo not found: $REPO"

cur="$(git rev-parse --abbrev-ref HEAD)"
[ "$cur" = "$BRANCH" ] || { echo "not on $BRANCH (on $cur); skipping"; exit 0; }

# Set aside tracked working-tree changes (e.g. live settings.json) so rebase can
# run. Untracked files are left in place (they don't block a rebase).
STASHED=0
if ! git diff --quiet || ! git diff --cached --quiet; then
  git stash push -m "sync-fork auto-stash $(date +%s)" && STASHED=1 && echo "stashed dirty tree"
fi
restore_stash() { if [ "$STASHED" = 1 ]; then git stash pop || echo "WARN: stash pop had conflicts; resolve manually"; fi; }

git fetch origin || { restore_stash; fail "git fetch origin failed"; }

if git rebase origin/main; then
  echo "rebase clean"
else
  echo "CONFLICT during rebase - aborting, NOT pushing"
  git rebase --abort
  restore_stash
  notify "Rebase conflict this week - aborted, nothing pushed. Resolve manually."
  exit 2
fi

restore_stash

if git push --force-with-lease fork "$BRANCH:$BRANCH"; then
  echo "pushed to fork OK"
  notify "Rebased onto origin/main and pushed to fork."
else
  fail "push to fork failed (force-with-lease rejected?) - check the repo"
fi

echo "===== done ====="
