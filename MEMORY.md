# MEMORY.md

## Harness / tooling quirks

- **`git_write` commit with explicit paths can spuriously fail on `dotfiles/tmux/.tmux.conf`** with "paths are ignored by one of your .gitignore files". Root cause: the tool's ignore pre-check mishandles the `!` re-inclusion pattern (`dotfiles/tmux/*` + `!dotfiles/tmux/.tmux.conf`); real `git add` handles it fine and the file is tracked. The add actually stages despite the error. Workaround: verify with `git_read op=status` (file will show as staged), then retry `git_write op=commit` **without** `paths`.
