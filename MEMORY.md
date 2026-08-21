# MEMORY.md

## Process rules

- To inspect the Helix runtime setup (config file, runtime directories, per-language LSP/grammar/formatter status), run `hx --health` / `hx --health <lang>`. Do **not** search `/nix/store` for the helix runtime — that trips the permission gate.
- Do **not** run `hx --grammar fetch/build` — it dumps grammars into `dotfiles/helix/runtime` (via the `~/.config/helix` out-of-store symlink), where they shadow nixpkgs' prebuilt `helix-runtime` grammars. Nix ships all grammars + queries; the repo runtime dir must stay deleted.

## Tool friction

- `fetch op=gh` with a guessed file path 404s with only a "list the repo root" hint. Monorepos (e.g. alacritty/alacritty keeps the crate in `alacritty/`) need a parent-dir listing instead. Proposed fix: on 404, fall back to listing the requested path's parent directory (or suggest it in the hint).
- `dotfiles/tmux/.tmux.conf` is tracked via gitignore negation (`dotfiles/tmux/*` + `!dotfiles/tmux/.tmux.conf`). The old-path pattern must stay anchored: `/tmux/`, never `tmux/` — unanchored it excludes `dotfiles/tmux`, and git's re-inclusion rule then makes the negation ineffective: `git add` refuses (reporting the dir as ignored) while `git check-ignore` says the file is fine. Workaround if it recurs: `git add -f`.
