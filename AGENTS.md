# Agent conventions — dotfiles-core

## Scope boundary (the one-sentence rule)

Only things that are **byte-identical on both machines and safe to publish to the world**
may be added to this repo — it is public.

## Invariants (violating one is a design change, not a workaround)

- **I1** Core is edited and pushed from the personal machine only. The work machine's clone
  pulls over anonymous HTTPS and cannot push.
- **I2** No secrets, no PII: no tokens, keys, `.env`, session files — and no names, email
  addresses, or account handles anywhere. GitHub handles are tolerated only inside remote
  URLs where technically unavoidable.
- **I3** No duplication across repos: machine repos reference core (include/symlink/source)
  or override additively. If you're copying a core file, the change belongs in core.
- **I4** Nothing destructive runs unattended. `brew bundle cleanup` (pruning) only ever runs
  behind `brew-sync.sh --prune` with interactive confirmation.
- **I5** Everything is idempotent: applying/running twice changes nothing the second time.
- **I6** One canonical path constant: shell code uses `$DOTFILES_HOME` / `$DOTFILES_CORE`;
  chezmoi templates use the `.workspace` data value. Never a literal workspace path.

## This repo is NOT a chezmoi source

Nothing here is applied to `$HOME` directly. Machine repos pull files from here via
`source`, `[include]`, `config-file`, symlinks, or env vars pointing into
`$DOTFILES_HOME/core`. The chezmoi naming conventions live in each machine repo's AGENTS.md.

## Safe vs unsafe operations

| Operation | Safety |
|---|---|
| Reading anything, `git diff`, `scripts/doctor.sh` | always safe (doctor is read-only) |
| Editing files here | safe — nothing takes effect until a machine sources/applies it |
| `scripts/brew-sync.sh` | installs missing packages; never removes |
| `scripts/brew-sync.sh --prune` | **uninstalls software — never run without an explicit human instruction** |
| `git push` | publishes to a public repo — only from the personal machine, only after the human reviews |
| `macos/defaults.sh` | writes macOS settings; idempotent, but affects the live machine |

## Where to add a thing

| Thing | Location |
|---|---|
| Shared package | `Brewfile` (sectioned, commented) |
| Shared alias / shell option / tool init | `zsh/20-aliases.zsh` / `zsh/00-options.zsh` / `zsh/30-tools.zsh` |
| Shared tool default flags | a config file (e.g. `ripgrep/config`), wired via env var in `zsh/30-tools.zsh` — not an alias |
| Shared git/terminal/prompt config | `git/config`, `ghostty/config`, `starship.toml` |
| Shared macOS setting | `macos/defaults.sh`, with a comment saying what it does in the UI |
| One-machine-only anything | that machine's repo — never here |
| Identity (name/email) | nowhere in any repo — prompted locally by chezmoi (machine repos' AGENTS.md) |
| A resolved design decision | `docs/DECISIONS.md` (dated ADR entry) |

## How to verify a change without touching the live machine

- Shell: `zsh -f -c 'export DOTFILES_CORE=$PWD; for f in zsh/*.zsh; do source $f; done'`
- Scripts: `shellcheck scripts/*.sh macos/*.sh` and `shfmt -d scripts/ macos/`
- The full chezmoi dry-run lives in the machine repos (their AGENTS.md) — core changes are
  picked up by pointing a dry-run's `.workspace` at this checkout.
- PII/secret scan before any commit: `git grep -iE '(@(gmail|proton|icloud)|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,})' -- ':!docs/DECISIONS.md'` should hit nothing unexpected.
