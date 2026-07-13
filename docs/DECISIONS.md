# Decisions (ADR log)

One dated entry per resolved open question, with the reason it beat the alternatives.
Newest at the bottom. All entries below were resolved 2026-07-13 during the plan review.

## 1. Core is a public repo (topology)

The draft's push-mirror required the personal machine to hold a work-account credential,
contradicting the "no cross-account auth, in either direction" objective. A read-only
deploy key would put a personal credential on the work machine instead. Public core
dissolves the problem: the work machine clones anonymously over HTTPS (read-only **by
transport**, so I1 is mechanical), there is no mirror to drift, and unattended pulls
need no unlocked anything. Core contains no PII by invariant, so the only cost is
world-readable shell config. **Alternatives rejected:** private + push-mirror, private +
deploy key.

## 2. SSH: on-disk keys, no password-manager agents, no host aliases

One ed25519 key per machine, passphrase in the Apple keychain — identical to the
previous working setup. Password-manager SSH agents (1Password/Bitwarden) would make
every git operation depend on an unlocked vault. With one GitHub identity per machine
and public core, no host aliasing or `insteadOf` rewriting is needed anywhere.
`~/.ssh/config` is chezmoi-managed with an `Include config.local` escape hatch for
untracked infra hosts.

## 3. Identity prompted locally; NO PII in any repo; no commit signing

Names/emails appear in no repo — not even the private ones (owner requirement).
chezmoi prompts once at init (`promptStringOnce`); values live only in the machine-local
config. Commit signing is not adopted (the previous setup had none); it's ~4 lines of
git config later if wanted. gnupg stays uninstalled.

## 4. Aliasing: conservative shims + `cd`→zoxide; config files over aliases

Shadow only drop-in commands (ls/ll/la/tree→eza, cat→bat). `grep` and `find` are NOT
shadowed — rg/fd flag semantics differ. Tool defaults live in config files
(`RIPGREP_CONFIG_PATH`, `BAT_CONFIG_PATH`, `FZF_DEFAULT_COMMAND`), not aliases. zoxide
takes over `cd` (`--cmd cd`): plain `cd` keeps working, partial names frecency-jump.

## 5. Workspace at `~/Developer/dotfiles`, defined once

Canonical definition is the `.workspace` data value in each machine repo's
`.chezmoi.toml.tmpl` (env `DOTFILES_HOME` overrides at init). Everything else — shell
vars, git include, ghostty include, starship symlink, external target — derives from it.

## 6. AI CLIs via Homebrew casks

`claude-code` (work) and `codex` (personal) install as casks: one package manager, fully
declarative, restored by bootstrap. Accepted trade-off: may lag the native installers by
days. **Alternative rejected:** native installers (undocumented install channel).

## 7. VS Code owned by Settings Sync

The Brewfile installs the app only. Settings Sync owns settings, keybindings, and
extensions — repo-managing `settings.json` fights the app's constant rewrites. The two
machines sync via their own GitHub accounts and stay independent.

## 8. Updates are manual; nothing is scheduled

`chezmoi update` by hand; core refreshes via the external's 168h window during any
apply. No launchd. "Set and forget" means convergence is one command, not a daemon.
Pruning is interactive-only (I4).

## 9. Full (non-shallow) clone of core everywhere

`--depth 1` would break pushing from the personal editing copy and saves nothing on a
repo this size. Both machine repos use identical external definitions.

## 10. uv owns Python; mise owns node + everything else; no brew pnpm

A brew-global pnpm fights per-project `packageManager` pins — corepack/mise own it.
Encoded in `zsh/30-tools.zsh`.

## 11. Secrets escape hatch (unused): age + identity in a password manager

The design needs no secrets (I2). If that ever changes: chezmoi's `age` encryption with
the identity file fetched manually from 1Password/Bitwarden — never `op`/`bw` calls at
apply time, which would couple every apply to an unlocked vault.

## 12. Fonts: all five verified in homebrew/cask (2026-07-13); no taps

The plan suspected `font-sf-mono-nerd-font-ligaturized` needed a third-party tap — it
doesn't. If a tap is ever added, Homebrew 6 requires `brew tap --trust` / Brewfile
`trusted: true`; note it here and in RUNBOOK.md when it happens.
