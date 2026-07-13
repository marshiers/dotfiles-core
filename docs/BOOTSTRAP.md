# Bootstrap: bare metal → working machine

Same procedure for both machines; only the machine name and repo URL differ. The exact
command with the real private-repo URL is in each machine repo's README (kept out of
this public file on purpose).

## Prerequisites (once, from any browser)

1. The three GitHub repos exist and are pushed: `dotfiles-core` (public, personal
   account), `dotfiles-personal` (private, personal account), `dotfiles-work`
   (private, work account).
2. You can sign in to the matching GitHub account to add an SSH key.

## The one command

```sh
curl -fsSL https://raw.githubusercontent.com/<personal>/dotfiles-core/main/scripts/bootstrap-workspace.sh \
  | bash -s -- <personal|work> <machine-repo-ssh-url>
```

What it does, in order (all idempotent — safe to re-run if interrupted):

1. Installs Homebrew (which installs the Xcode Command Line Tools, hence git).
2. `brew install git chezmoi` — the minimum; everything else arrives in step 5.
3. Generates `~/.ssh/github` (ed25519), stores the passphrase in the Apple
   keychain, prints the public key, and **waits while you add it to the matching GitHub
   account** (Settings → SSH and GPG keys). This is interactive step 1 of 2.
4. Clones the machine repo to `$DOTFILES_HOME/<machine>` (default `~/Developer/dotfiles`).
5. `chezmoi init --source=... --apply` — **interactive step 2 of 2: prompts once for git
   name + email.** These are stored ONLY in `~/.config/chezmoi/chezmoi.toml` on this
   machine; they never enter a repo. The apply then clones core (anonymous HTTPS),
   writes all dotfiles, installs every Brewfile package, and applies macOS defaults.
6. Symlinks `$DOTFILES_HOME/README.md` → core's WORKSPACE.md.

## After bootstrap

- Open a **new** shell (the login shell must pick up the new `~/.zshenv`).
- Run `$DOTFILES_HOME/core/scripts/doctor.sh` — everything should PASS.
- Recreate any ad-hoc SSH hosts you need in `~/.ssh/config.local` (untracked; copy from
  your password manager or the old machine's notes — never from a repo).
- Sign in to VS Code and enable Settings Sync (owns settings + extensions).
- Do **not** create a `~/.gitconfig` — git identity and config live in
  `~/.config/git/config`, which chezmoi manages.

## If this machine has existing dotfiles (not a fresh install)

`chezmoi apply` overwrites managed targets. Run `chezmoi diff` first and move anything
you care about into the machine repo or `conf.d/` before applying. (Moot on a wiped
machine — kept here for the day it isn't.)
