# 00-options.zsh — shell options, history, completion.
# Sourced first of the core modules by each machine's .zshrc loader.
# Safe to re-source; nothing here is destructive.

# Homebrew — Apple Silicon prefix is a hard constraint of this setup (ARCHITECTURE.md)
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

setopt AUTO_CD                # a bare directory name cd's into it
setopt INTERACTIVE_COMMENTS   # allow # comments at the prompt
setopt EXTENDED_GLOB
setopt NO_BEEP

export EDITOR="${EDITOR:-micro}"
export VISUAL="$EDITOR"

# --- History ---------------------------------------------------------------
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "${HISTFILE:h}"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # share across live sessions
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE      # a leading space keeps a command out of history

# --- Completion --------------------------------------------------------------
# zsh-completions must be on fpath BEFORE compinit — the classic post-Oh-My-Zsh
# casualty (acceptance 8.2 checks this on a fresh shell).
[[ -d /opt/homebrew/share/zsh-completions ]] && fpath=(/opt/homebrew/share/zsh-completions $fpath)
[[ -d /opt/homebrew/share/zsh/site-functions ]] && fpath=(/opt/homebrew/share/zsh/site-functions $fpath)

autoload -Uz compinit
_compdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump"
mkdir -p "${_compdump:h}"
# Full (slow) security scan at most once a day; otherwise trust the cached dump.
if [[ -f "$_compdump" && -n ${_compdump}(#qN.mh-24) ]]; then
  compinit -C -d "$_compdump"
else
  compinit -d "$_compdump"
  touch "$_compdump"
fi
unset _compdump

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'   # case-insensitive matching
