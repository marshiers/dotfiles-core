# 20-aliases.zsh — muscle-memory shims. Aliases affect interactive shells only;
# scripts are untouched.
# Policy (docs/DECISIONS.md #4): shadow a command only when the replacement is a
# drop-in for everyday flags. grep and find are deliberately NOT shadowed — rg and
# fd have different flag semantics; use them under their own names.
# Default flags for tools do NOT belong here — they live in config files (30-tools.zsh).

if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias ll='eza -la --git --group-directories-first'
  alias la='eza -a'
  alias lt='eza --tree --level=2'
  alias tree='eza --tree'                 # replaces the tree package
fi

command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never'

command -v lazygit >/dev/null 2>&1 && alias lg='lazygit'

# Deliberately no git shortcut aliases (gs/gc/gp...): git commands are typed in
# full, or use lazygit (lg).
