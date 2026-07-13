# Architecture

Living version of the rebuild plan (2026-07). Decisions and their rationale: `DECISIONS.md`.

## Repos

| Repo | Hosting | Visibility | Role |
|---|---|---|---|
| `dotfiles-core` | personal GitHub | **public** | everything shared by both machines |
| `dotfiles-personal` | personal GitHub | private | personal machine's chezmoi source |
| `dotfiles-work` | work GitHub | private | work machine's chezmoi source |

Core is public **by design**: it contains nothing identifying (no names, emails, machine
details — invariant I2), and public hosting is what removes every cross-account
credential. The work machine clones core over anonymous HTTPS and *cannot* push (I1 is
enforced by transport, not policy). The personal machine's clone gets an SSH push URL via
a `run_once` script and is the only editing copy.

## Invariants

- **I1** Core is edited/pushed from the personal machine only. The work clone is
  read-only by transport (anonymous HTTPS). Work-discovered improvements land in the work
  layer first and are promoted to core from home (RUNBOOK.md).
- **I2** No secrets and no PII in any repo — no tokens, private keys, `.env`, names, or
  email addresses. SSH keys are generated per machine and never synced. Git identity is
  prompted once by chezmoi and stored only in the machine-local config.
- **I3** A machine repo never copies a core file — it references (source / `[include]` /
  `config-file` / symlink / env var) or overrides additively.
- **I4** Nothing destructive runs unattended. Package pruning is `brew-sync.sh --prune`,
  interactive only. No scheduled jobs exist at all (DECISIONS.md #8).
- **I5** Idempotent everywhere: a second `chezmoi apply` changes nothing.
- **I6** One canonical path constant, two projections: chezmoi data `.workspace`
  (defined once in each machine repo's `.chezmoi.toml.tmpl`) renders into every template,
  including `~/.zshenv`, which exports it as `$DOTFILES_HOME` / `$DOTFILES_CORE` for
  shell code. No literal workspace paths anywhere.

## How a machine consumes core

1. The machine repo's `.chezmoiexternal.toml` declares `<workspace>/core` as a `git-repo`
   external: cloned on first apply, `git pull --ff-only` at most weekly.
2. `~/.zshenv` (rendered) exports `DOTFILES_HOME`/`DOTFILES_CORE`; `~/.config/zsh/.zshrc`
   (a loader, nothing else) sources `$DOTFILES_CORE/zsh/*.zsh` then `$ZDOTDIR/conf.d/*.zsh`.
3. `~/.config/git/config` (rendered) `[include]`s `core/git/config`, then adds identity.
4. `~/.config/ghostty/config` sets machine keys (font) and `config-file`-includes core.
   Ghostty loads includes AFTER the machine file and later values win — key sets must
   stay disjoint.
5. `~/.config/starship.toml` is a symlink into core.
6. `run_after` scripts call `core/scripts/brew-sync.sh` and `core/macos/defaults.sh`.

## Identity & SSH model

One GitHub identity per machine — so there are **no host aliases, no `insteadOf`
rewrites, no `includeIf` gitdir switching**. Each machine has a single on-disk ed25519
key (`~/.ssh/github` — no per-machine suffix, since a machine only ever has one
GitHub identity; passphrase in the Apple keychain) referenced by the one
`Host github.com` entry in its chezmoi-managed `~/.ssh/config`. Ad-hoc infra hosts live
in `~/.ssh/config.local`, untracked. No commit signing (DECISIONS.md #3).

## Package model

`core/Brewfile` (shared) + `<machine>/.brew/Brewfile.local` are concatenated and applied
by `brew-sync.sh` on every apply (fast no-op when satisfied). VS Code extensions and
settings are owned by VS Code Settings Sync, not the repos. Python belongs to `uv`;
node and every other runtime belong to `mise`.
