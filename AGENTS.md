# AGENTS.md

## Project

Personal dotfiles managed via [home-manager](https://nix-community.github.io/home-manager/) on Nix. Declaratively configures shell (Zsh), editors (Helix), terminals (Alacritty/Ghostty), tmux, GNOME, systemd services, and 150+ CLI/GUI packages.

## Key workflows

```bash
nixfmt home.nix dconf.nix           # format Nix files
home-manager switch -n               # dry-run before any Nix change
home-manager switch                  # apply configuration
shellcheck bin/*.sh shell/.aliasrc    # lint shell scripts
nix-locate <pkg-or-file>            # fast offline Nix package search (~40MB index)
```

## Critical conventions

- **Agent never runs `home-manager switch`** — dry-run (`-n`) only. User applies changes manually.
- **Aliases** go in `shell/.aliasrc`, **not** in `home.nix`'s `shellAliases` — no `home-manager switch` needed
- `modules/` contains opt-in Home Manager modules (browsers, git, packages, dotfiles, etc.). Import them from `home.nix` when needed. See individual files for usage comments.
- **`bin/encrypto.sh`** is dual-use (sourced or executed). When sourced, only `encrypt()` and `decrypt()` enter the shell environment. Never export `usage()` or `die()`.
- **Package installation** is done via `modules/packages/` (imported from home.nix) — never `nix-env -i` or `nix profile install`
- **`config.nix`** is gitignored per-user settings — do not commit, do not hardcode values
- **Go comes from [go-overlay](https://github.com/purpleclay/go-overlay)** (`pkgs.go-bin.latestStable`), not nixpkgs' `go` — overlay applied in `home.nix`, channel added in `bin/install.sh`
- **Tilish default** is `main-vertical` layout, `enforce` is `none`
- **tmux prefix** is `M-;` (Alt+;), not C-b
- **tmux reload**: `prefix :source-file ~/.tmux.conf`

## Before committing

1. `nixfmt home.nix dconf.nix`
2. `home-manager switch -n` must pass
3. `shellcheck bin/*.sh shell/.aliasrc`
4. Git hooks (`hooks/pre-commit`) auto-scan for secrets — don't bypass them
