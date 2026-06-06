# Core packages that are always installed, regardless of toggles.

{ pkgs, ... }:

{
  core = with pkgs; [
    helix # modal text editor
    tmux # terminal multiplexer

    yazi # terminal file manager
    ueberzugpp # draw images on terminals
    broot # interactive file tree
    ripgrep # fast recursive grep
    fd # fast find replacement
    bat # cat with syntax highlighting
    eza # modern ls
    zoxide # smarter cd command
    jq # JSON processor
    curl # URL transfer tool
    wget # file downloader
    coreutils # GNU core utilities
    gnupg # GNU Privacy Guard
    age # modern file encryption
    mosh # mobile shell
    openssh_hpn # OpenSSH with HPN patches
    rlwrap # readline wrapper
    delta # syntax-highlighting diff
    difftastic # structural diff
    yt-dlp # video downloader

    duf # modern df
    htop # interactive process viewer
    btop # resource monitor
    lsof # list open files
    ncdu # disk usage analyzer
    fastfetch # system info fetcher

    xclip # X11 clipboard
    wl-clipboard # Wayland clipboard
    xsel # X11 selection tool
    zsh-completions # extra zsh completions

    # Core formatters & linters (always installed, used by `make all`)
    nixfmt # Nix formatter
    shellcheck # shell linter

    nerd-fonts.hack # Hack Nerd Font
    nerd-fonts.fira-code # Fira Code Nerd Font
    noto-fonts-color-emoji # emoji font

    rmpc # TUI client for MPD (Music Player Daemon)
  ];
}
