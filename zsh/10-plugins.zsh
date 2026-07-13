# 10-plugins.zsh — zsh plugins, loaded directly from Homebrew (no framework).
# ORDER MATTERS: zsh-syntax-highlighting must be sourced LAST of all plugins.
# (zsh-completions is fpath-only and is handled in 00-options.zsh, before compinit.)

[[ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

[[ -r /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
