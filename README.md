# skel

Personal dotfiles managed via [home-manager](https://nix-community.github.io/home-manager/) on Nix.
Declaratively configures 150+ packages: shell, editors, terminals, tmux, fonts, GNOME, systemd.

## Quick start

```bash
git clone https://github.com/lfaoro/skel --recurse-submodules
cd skel
./bin/install.sh
```

The installer will prompt you for feature toggles to generate `config.nix`:

```
==> configure your environment
Install developer tools (Go, Rust, Zig, Node, LSPs)? [y/N]:
Apply GNOME dconf settings? [y/N]:
Install GUI applications? [y/N]:
Install network scanning tools (nmap, tshark, etc.)? [y/N]:
Install miscellaneous CLI tools (jump, lynx, etc.)? [y/N]:
Remap Caps Lock to Ctrl? [y/N]:
```

All defaults are conservative (off). You can re-run or edit `config.nix` anytime later. Non-interactive runs (e.g. piped) silently default to all-off. When GUI is enabled, install also sets up nixGL and Brave browser policy.

## What's configured

- **Shell**: Zsh with aliases, autosuggestions, syntax highlighting, fzf, zoxide
- **Editor**: Helix with LSPs (Go, Rust, Python, TS, Bash, YAML, Nix, Markdown)
- **Terminal**: Alacritty (primary), Ghostty
- **Multiplexer**: tmux with tilish layout (`M-;` prefix, `main-vertical`)
- **Git**: gitui, delta diff, lazygit, GPG signing
- **File manager**: yazi
- **System**: systemd user services (cron jobs, mosh, syncthing)
- **Fonts**: Hack Nerd Font, Fira Code Nerd Font, Noto Emoji
- **Security**: pre-commit hooks scan for secrets, gocryptfs

## Customization

Edit `config.nix` (gitignored) before applying:

```nix
{
  username     = "user";
  homedir      = "/home/user";
  useDevTools  = true;  # Go, Rust, Zig, Node, LSPs
  useDconf     = true;  # GNOME dconf settings
  useGUI         = true;  # GUI apps (KeePassXC, Telegram, Brave, etc.)
  useNetworkTools = false; # nmap, tshark, etc.
  useMisc        = false; # jump, lynx, osquery, etc.

  gitName          = "Your Name";
  gitEmail         = "you@example.com";
  gitGpgKey        = "";   # e.g. "ABCD1234..." or leave empty to disable
  gitSignByDefault = false;
}
```

Then:

```bash
home-manager switch -n  # dry-run
home-manager switch     # apply
```

## Daily maintenance

```bash
hm          # home-manager (aliased: unsets __HM_SESS_VARS_SOURCED first)
upgrade     # full update: snap + apt + nix-channel + home-manager switch
clean       # journals, apt cache, nix store gc
note        # take a note
note todo   # todo list
```

## Adding packages / dotfiles

For new symlinked config directories, add an entry in `modules/dotfiles.nix`:

```nix
".config/newapp" = "dotfiles/newapp";  # ~/.config/newapp -> ~/skel/dotfiles/newapp
```

For aliases, add to `shell/.aliasrc` (no `home-manager switch` needed).

For packages, add to the appropriate list in `modules/packages/<category>.nix`, then `home-manager switch`.

Never use `nix-env -i` or `nix profile install`.

## Repository structure

```
skel/
├── home.nix            # main home-manager config (mostly wiring)
├── dconf.nix           # GNOME dconf settings
├── config.nix          # gitignored per-user settings
├── modules/            # extracted Home Manager modules
│   ├── packages/       # dev, gui, network, misc, core packages
│   ├── dotfiles.nix    # symlink management
│   ├── git.nix
│   ├── syncthing.nix
│   └── ...
├── dotfiles/           # symlinked config directories
├── shell/              # Zsh/Bash source files
├── bin/                # utility scripts
├── hooks/              # git hooks (pre-commit, pre-push)
├── etc/                # system-level config
└── scratch/            # experimental (gitignored)
```

## License

Source Available — see LICENSE.md
