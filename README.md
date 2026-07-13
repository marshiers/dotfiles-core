# dotfiles-core

Everything shared by **both** Macs (personal + work): shell, prompt, git defaults, terminal,
shared packages, macOS defaults, scripts, and all documentation. This repo is **public** —
it must never contain identity, machine names, or secrets (see `AGENTS.md`).

It is consumed by each machine's private chezmoi repo as a
[chezmoi external](https://www.chezmoi.io/reference/special-files/chezmoiexternal-format/):
cloned to `$DOTFILES_HOME/core` on first apply, pulled `--ff-only` weekly.

## What belongs here / what doesn't

Anything identical on both machines belongs here — if you'd be annoyed to write it twice,
it's core. Anything with a name, email, account, font choice, or that only one machine
needs belongs in that machine's repo instead.

## Bootstrap a machine

See [`docs/BOOTSTRAP.md`](docs/BOOTSTRAP.md). One command on bare metal.

## Most common changes

| Change | Where |
|---|---|
| Add a shared package | `Brewfile` (then `chezmoi apply` or `scripts/brew-sync.sh`) |
| Add a shared alias | `zsh/20-aliases.zsh` |
| Add a machine-only thing | that machine's repo, **not** here |
| Publish core changes | commit + `git push` (personal machine only — see invariant I1) |

## Everything else

`docs/ARCHITECTURE.md` (design + invariants) · `docs/RUNBOOK.md` (day-2 operations) ·
`docs/INVENTORY.md` (what's installed and why) · `docs/DECISIONS.md` (ADR log) ·
`docs/WORKSPACE.md` (the `$DOTFILES_HOME` directory explained)
