#!/bin/bash
# what:        read-only sanity checks for the whole dotfiles setup
# when:        after bootstrap, and whenever something feels off
# destructive: no — prints findings, changes nothing

set -uo pipefail # deliberately NOT -e: report every finding, then exit non-zero on FAILs

fail=0
ok() { printf 'PASS  %s\n' "$1"; }
warn() { printf 'WARN  %s\n' "$1"; }
bad() {
  printf 'FAIL  %s\n' "$1"
  fail=1
}

DOTFILES_HOME="${DOTFILES_HOME:-$HOME/Developer/dotfiles}"
CORE="$DOTFILES_HOME/core"

# --- workspace shape ------------------------------------------------------
if [[ -d "$CORE" ]]; then ok "core present at $CORE"; else bad "core missing at $CORE"; fi

MACHINE=""
for m in personal work; do
  [[ -d "$DOTFILES_HOME/$m" ]] && MACHINE="$m"
done
if [[ -n "$MACHINE" ]]; then ok "machine layer: $MACHINE"; else bad "no machine repo under $DOTFILES_HOME"; fi
if [[ -d "$DOTFILES_HOME/personal" && -d "$DOTFILES_HOME/work" ]]; then
  bad "BOTH machine repos cloned — a machine must have exactly one (ARCHITECTURE.md)"
fi

# --- core remote discipline (invariant I1) --------------------------------
if [[ -d "$CORE/.git" ]]; then
  push_url=$(git -C "$CORE" remote get-url --push origin 2>/dev/null || echo "")
  if [[ "$MACHINE" == "personal" ]]; then
    if [[ "$push_url" == git@github.com:* ]]; then
      ok "core push URL is SSH (this is the editing copy)"
    else
      warn "core push URL is '$push_url' — run_once_after_30-core-remote.sh not applied yet?"
    fi
    unpushed=$(git -C "$CORE" rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo 0)
    if [[ "$unpushed" -eq 0 ]]; then
      ok "core has no unpushed commits"
    else
      warn "core has $unpushed unpushed commit(s) — the work machine can't see them"
    fi
  elif [[ "$MACHINE" == "work" ]]; then
    if [[ "$push_url" == https://* ]]; then
      ok "core push URL is anonymous HTTPS (read-only by transport — I1 holds)"
    else
      bad "work machine core push URL is '$push_url' — must stay anonymous HTTPS (I1)"
    fi
  fi
  if [[ -z "$(git -C "$CORE" status --porcelain 2>/dev/null)" ]]; then
    ok "core working tree clean"
  else
    warn "core has uncommitted local changes (weekly --ff-only refresh will warn)"
  fi
fi

# --- identity (prompted locally, never in repos) ---------------------------
email=$(git config --get user.email 2>/dev/null || echo "")
if [[ -n "$email" ]]; then
  ok "git user.email resolves"
else
  bad "git user.email not set — rerun: chezmoi init --source=\"$DOTFILES_HOME/$MACHINE\""
fi

# --- work/personal isolation (acceptance 8.2: verify by grep, not memory) --
if [[ "$MACHINE" == "work" && -d "$CORE/.git" ]]; then
  # The personal handle is allowed to appear in exactly one place: core's own
  # clone URL. Derive it from there instead of hardcoding it (I2).
  core_owner=$(git -C "$CORE" remote get-url origin 2>/dev/null |
    sed -E 's#.*github\.com[:/]([^/]+)/.*#\1#')
  if [[ -n "$core_owner" ]]; then
    hits=$(grep -RIls "$core_owner" \
      "$HOME/.ssh/config" "$HOME/.config/git" "$HOME/.gitconfig" 2>/dev/null || true)
    if [[ -z "$hits" ]]; then
      ok "no personal-account references outside the core clone URL"
    else
      bad "personal account '$core_owner' referenced in: $(echo "$hits" | tr '\n' ' ')"
    fi
  fi
fi

# --- packages ----------------------------------------------------------------
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  composed=$(mktemp)
  cat "$CORE/Brewfile" "$DOTFILES_HOME/$MACHINE/.brew/Brewfile.local" >"$composed" 2>/dev/null
  if brew bundle check --file="$composed" >/dev/null 2>&1; then
    ok "brew bundle check: satisfied"
  else
    warn "brew packages missing — run: chezmoi apply (or core/scripts/brew-sync.sh)"
  fi
  rm -f "$composed"
else
  bad "Homebrew not installed at /opt/homebrew"
fi

# --- shell -------------------------------------------------------------------
if zsh -ic 'whence compdef >/dev/null' 2>/dev/null; then
  ok "completions initialise in a fresh interactive shell"
else
  bad "compinit/compdef broken in a fresh shell (fpath ordering? see zsh/00-options.zsh)"
fi

# --- broken symlinks under ~/.config ------------------------------------------
broken=$(find "$HOME/.config" -maxdepth 3 -type l ! -exec test -e {} \; -print 2>/dev/null || true)
if [[ -z "$broken" ]]; then
  ok "no broken symlinks under ~/.config"
else
  warn "broken symlinks: $(echo "$broken" | tr '\n' ' ')"
fi

exit "$fail"
