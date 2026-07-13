# Inventory — what's installed, where, and why

Reconcile this table against reality after each cutover (P6). Names verified against
Homebrew on 2026-07-13; all casks live in `homebrew/cask` — **no taps required**
(including `font-sf-mono-nerd-font-ligaturized`, which was suspected to need one).

## Core (both machines)

| Tool | What / why | Replaces |
|---|---|---|
| starship | prompt | Oh My Zsh |
| zsh-autosuggestions / zsh-syntax-highlighting / zsh-completions | the three plugins, loaded directly | Oh My Zsh plugin system |
| git, gh, lazygit, git-delta | VCS + GitHub CLI + TUI + diff pager | — |
| chezmoi | dotfiles manager | — |
| eza | `ls`, and `tree` via `--tree` | ls, **tree** |
| bat | `cat` with highlighting (config in `core/bat/`) | cat |
| ripgrep | `rg` (config in `core/ripgrep/`; NOT aliased to grep) | grep (in practice) |
| fd | find replacement; feeds fzf | find (in practice) |
| fzf | fuzzy finder | — |
| zoxide | frecency `cd` (takes over `cd`) | plain cd |
| mise | node + all runtimes except Python | nvm etc. |
| uv | Python: interpreters, venvs, tools | pyenv/pip/pipx |
| jq, btop, wget, micro, shellcheck, shfmt | utilities; micro is `$EDITOR` | nano (micro) |
| appcleaner, betterdisplay, coteditor, figma, ghostty, iina, maccy, rectangle, visual-studio-code | GUI apps | — |
| 5 nerd fonts | see Brewfile fonts section | — |

## Personal only

| Tool | Why |
|---|---|
| 1password, 1password-cli | password manager (CLI for general use; never called by chezmoi) |
| codex (cask) | OpenAI Codex CLI |
| dropbox, firefox, pixelmator-pro, tailscale, todoist, transmission, typora | apps |
| mactex-no-gui, tex-fmt | TeX toolchain (PATH wired in personal `conf.d/50-local.zsh`) |

## Work only

| Tool | Why |
|---|---|
| bitwarden | password manager |
| claude-code (cask) | Claude Code CLI |
| google-chrome, localsend, microsoft-teams | apps |

## Deliberately absent

| Tool | Superseded by |
|---|---|
| tree | `eza --tree` alias |
| Oh My Zsh | starship + three plugins loaded directly |
| gnupg | nothing — commit signing not adopted (DECISIONS.md #3) |
| pnpm (as brew formula) | mise/corepack, pinned per-project |
| VS Code extensions via Brewfile | VS Code Settings Sync (DECISIONS.md #7) |
