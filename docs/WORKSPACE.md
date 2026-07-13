# The dotfiles workspace (`$DOTFILES_HOME`)

A plain directory — **not** a git repo — where the dotfiles repos live side by side so they
can be opened, edited, and reasoned about together. Created by
`core/scripts/bootstrap-workspace.sh`; default location `~/Developer/dotfiles`.

```
$DOTFILES_HOME/
├── README.md      → symlink to core/docs/WORKSPACE.md (this file)
├── core/          → clone of dotfiles-core (public), managed by chezmoi as an external
└── personal/      → clone of this machine's private chezmoi repo
    (or work/ — a machine has EXACTLY ONE of the two, never both)
```

## Rules

- **Two children per machine.** `personal/` never exists on the work machine and vice
  versa. `doctor.sh` fails if it sees both.
- **The workspace is reconstructable, NOT disposable.** The live shell sources
  `core/zsh/*` from here, the prompt config and terminal config point into it, and
  `core/` may hold uncommitted edits (on the personal machine). Deleting it breaks your
  shell until you re-bootstrap — everything is recoverable from the remotes, but don't
  casually `rm -rf` it.
- **`core/` is updated by chezmoi**, not by you, on the work machine (weekly `--ff-only`
  pull during apply). On the personal machine it doubles as the editing copy — a pull
  that would clobber local work refuses and warns instead (see RUNBOOK.md).
- All references to this directory go through `$DOTFILES_HOME` / `$DOTFILES_CORE` (shell)
  or the `.workspace` chezmoi data value (templates) — never a hardcoded path.
