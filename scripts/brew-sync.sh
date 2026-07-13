#!/bin/bash
# what:        compose core Brewfile + this machine's Brewfile.local, install what's missing
# when:        every `chezmoi apply` (via run_after_10-brew.sh) — fast no-op when satisfied.
#              Also safe to run by hand.
# destructive: NOT by default; never upgrades-by-surprise beyond what `brew bundle` does.
#              `--prune` UNINSTALLS packages absent from the Brewfiles — it requires an
#              interactive yes and must never run unattended (invariant I4).

set -euo pipefail

[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

DOTFILES_HOME="${DOTFILES_HOME:-$HOME/Developer/dotfiles}"
CORE_BREWFILE="$DOTFILES_HOME/core/Brewfile"

# Exactly one machine layer exists per machine (ARCHITECTURE.md); find it.
LOCAL_BREWFILE=""
for m in personal work; do
  if [[ -f "$DOTFILES_HOME/$m/.brew/Brewfile.local" ]]; then
    LOCAL_BREWFILE="$DOTFILES_HOME/$m/.brew/Brewfile.local"
  fi
done

[[ -f "$CORE_BREWFILE" ]] || {
  echo "brew-sync: core Brewfile missing at $CORE_BREWFILE" >&2
  exit 1
}
[[ -n "$LOCAL_BREWFILE" ]] || {
  echo "brew-sync: no machine Brewfile.local found under $DOTFILES_HOME" >&2
  exit 1
}

COMPOSED="$(mktemp)"
trap 'rm -f "$COMPOSED"' EXIT
cat "$CORE_BREWFILE" "$LOCAL_BREWFILE" >"$COMPOSED"

if [[ "${1:-}" == "--prune" ]]; then
  echo "brew-sync: packages installed but NOT declared in any Brewfile:"
  brew bundle cleanup --file="$COMPOSED" || true
  read -r -p "Uninstall everything listed above? [y/N] " answer
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    brew bundle cleanup --force --file="$COMPOSED"
  else
    echo "brew-sync: prune aborted, nothing removed"
  fi
  exit 0
fi

# Fast path: everything declared is present.
if brew bundle check --file="$COMPOSED" >/dev/null 2>&1; then
  echo "brew-sync: satisfied ($(basename "$CORE_BREWFILE") + $(basename "$LOCAL_BREWFILE"))"
  exit 0
fi

brew bundle install --file="$COMPOSED"
