# dotfiles-core Brewfile — packages shared by BOTH machines.
# Machine-only packages belong in <machine>/.brew/Brewfile.local, never here.
# Installed by core/scripts/brew-sync.sh, composed with the machine's Brewfile.local.
# All names verified against homebrew/core + homebrew/cask on 2026-07-13 — no taps needed.

# --- Shell & prompt --------------------------------------------------------
brew "starship"                 # prompt (replaces Oh My Zsh)
brew "zsh-autosuggestions"      # inline history suggestions (sourced in zsh/10-plugins.zsh)
brew "zsh-syntax-highlighting"  # must be sourced LAST — see zsh/10-plugins.zsh
brew "zsh-completions"          # extra completions; on fpath before compinit (zsh/00-options.zsh)

# --- Git & GitHub -----------------------------------------------------------
brew "git"
brew "git-delta"                # syntax-highlighted diff pager (wired in git/config)
brew "lazygit"                  # git TUI
brew "gh"                       # GitHub CLI
brew "chezmoi"                  # dotfiles manager

# --- Modern CLI replacements ------------------------------------------------
# Policy: shadow only drop-in commands (zsh/20-aliases.zsh); defaults via config
# files, not aliases (zsh/30-tools.zsh). See docs/DECISIONS.md #4.
brew "eza"                      # ls (and tree, via --tree)
brew "bat"                      # cat
brew "ripgrep"                  # rg — NOT aliased to grep; defaults in ripgrep/config
brew "fd"                       # find replacement, also feeds fzf
brew "fzf"                      # fuzzy finder
brew "zoxide"                   # frecency cd — takes over `cd` (zsh/30-tools.zsh)

# --- Runtimes (docs/DECISIONS.md #10: uv owns Python, mise owns the rest) ---
brew "mise"
brew "uv"

# --- Utilities ---------------------------------------------------------------
brew "jq"
brew "btop"
brew "wget"
brew "micro"                    # terminal editor (replaces nano as $EDITOR)
brew "shellcheck"
brew "shfmt"

# --- GUI apps -----------------------------------------------------------------
cask "appcleaner"
cask "betterdisplay"
cask "coteditor"
cask "figma"
cask "firefox"
cask "ghostty"
cask "iina"
cask "logi-options+"        # Logitech Options+ — was "logitech-options"; that cask is deprecated (EOL 2026-12-12)
cask "maccy"
cask "rectangle"
cask "visual-studio-code"       # settings + extensions via Settings Sync (DECISIONS.md #7)

# --- Fonts (all in homebrew/cask — verified, no font tap required) ------------
cask "font-atkynson-mono-nerd-font"
cask "font-blex-mono-nerd-font"
cask "font-geist-mono-nerd-font"
cask "font-jetbrains-maple-mono-nf"
cask "font-sf-mono-nerd-font-ligaturized"

# Deliberately NOT installed (see docs/INVENTORY.md):
#   tree (eza --tree), gnupg (no signing), pnpm (mise/corepack owns it per-project)
