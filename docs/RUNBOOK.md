# Runbook — day-2 operations

## Add a package

- **Both machines:** add to `core/Brewfile` (in its section, with a comment), then
  `chezmoi apply` (or run `core/scripts/brew-sync.sh` directly).
- **This machine only:** add to `<machine>/.brew/Brewfile.local`, then `chezmoi apply`.
- Wrong-place test: if you're about to add the same line to both machine repos, it
  belongs in core (I3).

## Add an alias / shell config

- Shared → `core/zsh/20-aliases.zsh` (or the module that fits). Takes effect in new
  shells immediately on the machine where you edited; on the other machine after core is
  pushed + refreshed.
- Machine-only → `<machine>/dot_config/zsh/conf.d/50-local.zsh`, then `chezmoi apply`.
- Default flags for a CLI tool → a config file in core wired via env var in
  `30-tools.zsh` (see ripgrep/bat) — not an alias.

## Edit and publish core (personal machine only)

```sh
cd "$DOTFILES_CORE"   # this clone IS the editing copy
# edit, then:
git add -p && git commit && git push
```
The work machine picks it up on its next apply after the weekly refresh — or force it:
`chezmoi apply --refresh-externals` (alias `-R`).

## Promote a work-discovered improvement to core (invariant I1)

1. On the work machine: put it in the work layer (`conf.d/`, `Brewfile.local`) and note it.
2. At home: make the change in core, commit, push.
3. Next time on the work machine: `chezmoi apply -R`, then delete the now-shadowed work
   layer copy.

## Update a machine

`chezmoi update` = pull the machine repo + apply. Core refreshes at most weekly during
any apply; add `-R` to force it. Nothing is scheduled (DECISIONS.md #8) — set-and-forget
means *converges whenever you run it*, not *runs itself*.

## Prune packages (destructive — the ONLY destructive operation)

```sh
core/scripts/brew-sync.sh --prune   # lists, asks y/N, only then uninstalls
```
Never run unattended, never scripted (I4).

## Known behaviours (not bugs)

- **Weekly core pull fails with "--ff-only" on the personal machine**: core has local
  uncommitted/unpushed edits and upstream moved. This is the designed protection —
  finish the local work, `git pull --rebase`, push.
- **First apply after a core push does nothing on the other machine**: the external
  refresh window (168h) hasn't elapsed. Use `chezmoi apply -R`.
- **`chezmoi doctor` complains about the external's dirty worktree** (personal machine,
  mid-edit): expected; commit or stash when done.

## Health check

`core/scripts/doctor.sh` — read-only; run it whenever something feels off.
