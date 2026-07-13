# 30-tools.zsh — tool activation and config-file defaults. Sourced last of the
# core modules, before the machine's conf.d/.
# Runtime ownership (docs/DECISIONS.md #10): uv owns Python entirely; mise owns
# node and every other runtime. Never `mise use` python.

# Config-over-alias: default flags live in files, not shell aliases.
export RIPGREP_CONFIG_PATH="$DOTFILES_CORE/ripgrep/config"
export BAT_CONFIG_PATH="$DOTFILES_CORE/bat/config"

if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"

# cd IS zoxide on these machines (docs/DECISIONS.md #4): plain `cd path` still
# works; `cd partial-name` frecency-jumps; `cdi` is the interactive picker.
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh --cmd cd)"

command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

# Prompt goes last.
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
