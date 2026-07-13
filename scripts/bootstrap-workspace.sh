#!/bin/bash
# what:        bare-metal bootstrap — Homebrew, chezmoi, SSH key, workspace, first apply
# when:        run ONCE on a fresh machine:
#                curl -fsSL https://raw.githubusercontent.com/<personal>/dotfiles-core/main/scripts/bootstrap-workspace.sh \
#                  | bash -s -- <personal|work> <machine-repo-ssh-url>
#              The exact command (with real URLs) is in each machine repo's README —
#              deliberately not in this public file.
# destructive: no — skips anything that already exists

set -euo pipefail

MACHINE="${1:?usage: bootstrap-workspace.sh <personal|work> <machine-repo-ssh-url>}"
MACHINE_REPO_URL="${2:?usage: bootstrap-workspace.sh <personal|work> <machine-repo-ssh-url>}"
if [[ "$MACHINE" != "personal" && "$MACHINE" != "work" ]]; then
  echo "machine must be 'personal' or 'work'" >&2
  exit 1
fi

# Default must match .chezmoi.toml.tmpl in the machine repos (that template is the
# canonical definition — invariant I6). Override by exporting DOTFILES_HOME before
# running; chezmoi init below inherits it.
DOTFILES_HOME="${DOTFILES_HOME:-$HOME/Developer/dotfiles}"
export DOTFILES_HOME

echo "==> [1/6] Homebrew"
if [[ ! -x /opt/homebrew/bin/brew ]]; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "==> [2/6] Minimum tools (the rest arrives via brew-sync on first apply)"
brew install git chezmoi

echo "==> [3/6] SSH key for the $MACHINE GitHub account"
# One key per machine and one GitHub account per machine, so no suffix is needed
KEY="$HOME/.ssh/github"
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
if [[ ! -f "$KEY" ]]; then
  ssh-keygen -t ed25519 -f "$KEY" -C "github"
  # store the passphrase in the Apple keychain so pushes don't re-prompt
  ssh-add --apple-use-keychain "$KEY" || true
  echo
  echo "Add this public key to the $MACHINE GitHub account (Settings -> SSH and GPG keys):"
  echo
  cat "${KEY}.pub"
  echo
  read -r -p "Press Enter once the key is added on github.com ... " </dev/tty
fi
if ! grep -qs "github.com" "$HOME/.ssh/known_hosts" 2>/dev/null; then
  ssh-keyscan -t ed25519 github.com >>"$HOME/.ssh/known_hosts" 2>/dev/null
fi

echo "==> [4/6] Workspace + machine repo"
mkdir -p "$DOTFILES_HOME"
if [[ ! -d "$DOTFILES_HOME/$MACHINE" ]]; then
  # ~/.ssh/config doesn't exist yet (chezmoi writes it), so pick the key explicitly
  GIT_SSH_COMMAND="ssh -i $KEY -o IdentitiesOnly=yes" \
    git clone "$MACHINE_REPO_URL" "$DOTFILES_HOME/$MACHINE"
fi

echo "==> [5/6] First chezmoi apply"
echo "    (prompts ONCE for git name/email — stored locally only, never in a repo;"
echo "     then clones core, installs packages, applies macOS defaults)"
chezmoi init --source="$DOTFILES_HOME/$MACHINE" --apply

echo "==> [6/6] Workspace README symlink"
ln -sf "$DOTFILES_HOME/core/docs/WORKSPACE.md" "$DOTFILES_HOME/README.md"

echo
echo "Bootstrap complete. Open a NEW shell, then run:"
echo "  $DOTFILES_HOME/core/scripts/doctor.sh"
