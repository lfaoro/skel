# nix-store --verify --check-contents --repair
# https://nix-community.github.io/home-manager/options.html
{
  config,
  pkgs,
  lib,
  ...
}:

let
  configOpt = import ./config.nix;

  # ── Optional / disabled modules ─────────────────────────────────────
  # These are kept in separate files so they don't clutter the main
  # configuration when not in active use. Copy the import line into the
  # imports list below (or your personal config) to enable.
  #
  # Brave (with nixGL wrapper + strong privacy flags + extensions):
  #   imports = [ ./modules/brave.nix ];
  #
  # Librewolf (strict privacy settings):
  #   imports = [ ./modules/librewolf.nix ];
in

{
  imports = lib.optionals configOpt.useDconf [ ./dconf.nix ] ++ [
    ./services.nix
    ./modules/git.nix
    ./modules/syncthing.nix
    ./modules/packages
    ./modules/dotfiles.nix
  ];

  # ── Base ───────────────────────────────────────────────────────────

  home.username = configOpt.username;
  home.homeDirectory = configOpt.homedir;
  home.stateVersion = "24.11";

  # We intentionally track nixpkgs-unstable + home-manager/master (see bin/install.sh:83).
  # Their internal release strings (e.g. 26.05 vs 26.11) can drift even when the modules
  # are compatible; the check is a safeguard for release-branch users, not rolling ones.
  home.enableNixpkgsReleaseCheck = false;

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    # Fresh Go toolchains (updated within hours of go.dev releases) instead of
    # nixpkgs-unstable's `go`. Channel is registered in bin/install.sh.
    (import <go-overlay>)
  ];

  targets.genericLinux.enable = true;

  nix.package = pkgs.nix;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Prebuilt go-overlay toolchains/tools are served from their public Cachix
  # cache, so withDefaultTools (gopls, dlv, golangci-lint, …) is a cache hit.
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://go-overlay.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "go-overlay.cachix.org-1:rJ155O3K6WUyUcoKE4MqcC6JcLlK2vPXnP5/76BxWD8="
  ];

  xdg.enable = true;
  xdg.mime.enable = true;
  fonts.fontconfig.enable = true;

  # ── Packages ───────────────────────────────────────────────────────

  home.packages =
    with pkgs;
    config.myPackages.gui
    ++ config.myPackages.dev
    ++ config.myPackages.network
    ++ config.myPackages.misc
    ++ config.myPackages.core;

  # ── Dotfiles ───────────────────────────────────────────────────────

  # Managed in ./modules/dotfiles.nix

  # ── Shell environment ──────────────────────────────────────────────

  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
    SUDO_EDITOR = "hx";

    XCURSOR_SIZE = "32";

    PAGER = "bat";
    BAT_THEME = "Catppuccin Mocha";

    DOT = "$HOME/skel";
    WWW_HOME = "https://lite.duckduckgo.com/lite/?kae=d&kp=-2&kz=-1&kav=1&kaj=m&kau=-1&kaq=-1&kap=-1&kao=-1&kax=-1&kak=-1&kay=b&k1=-1&q=$1";
    LYNX_CFG = "$HOME/.config/lynx/lynx.cfg";
    LYNX_LSS = "$HOME/.config/lynx/lynx.lss";

    LANG = "en_US.UTF-8";
  }
  // builtins.listToAttrs (
    map
      (v: {
        name = "LC_${v}";
        value = "en_US.UTF-8";
      })
      [
        "ADDRESS"
        "IDENTIFICATION"
        "MEASUREMENT"
        "MONETARY"
        "NAME"
        "NUMERIC"
        "PAPER"
        "TELEPHONE"
        "TIME"
      ]
  );

  home.sessionPath = [
    "$HOME/skel/bin"
    "$HOME/go/bin"
    "$HOME/.cargo/bin"
    "/usr/local/go/bin"
    "$HOME/.local/bin"
  ];

  # ── Programs ───────────────────────────────────────────────────────
  programs.direnv.enable = true;
  programs.command-not-found.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  # https://reasoniamhere.com/2014/01/11/outrageously-useful-tips-to-master-your-z-shell/
  # https://strcat.de/zsh/#tipps
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    autocd = true;
    enableCompletion = false;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "emacs";
    history = {
      size = 10000;
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    # home.sessionPath doesn't work in home-manager, this is a workaround.
    # https://github.com/nix-community/home-manager/issues/2991
    profileExtra = lib.optionalString (config.home.sessionPath != [ ]) ''
      export PATH="$PATH''${PATH:+:}${lib.concatStringsSep ":" config.home.sessionPath}"
    '';

    initContent = ''
      source "$HOME/.sec/keys" || :

      stty -ixon

      if [[ -e $(which jump) ]]; then
          eval "$(jump shell zsh)"
      fi

      autoload -Uz vcs_info
      zstyle ':vcs_info:git:*' formats ' %b'
      zstyle ':vcs_info:git:*' actionformats '%b|%a'
      precmd_functions+=(_smartx_vcs_info)
      _smartx_vcs_info() {
        vcs_info
        psvar[1]="$vcs_info_msg_0_"
      }

      PROMPT="%(?.%F{green}√.%F{red}?)%f%(1j. %F{yellow}[%j]%f.) %n %B%F{240}%2~%f%b%F{cyan}%1v%f > ";

      if [ -n "$TMUX" ]; then
          precmd_functions+=(_set_tmux_window_name)
          _set_tmux_window_name() { tmux rename-window "''${PWD:t}" 2>/dev/null }
      fi

      source "$HOME/skel/shell/dotup.zsh" || :
      source "$HOME/skel/shell/first_word.zsh" || :
      source "$HOME/skel/shell/.aliasrc" || :
    '';
  };

  programs.vscodium = {
    enable = configOpt.useGUI;
    profiles.default.userSettings = {
    };
    profiles.default.extensions = [
      pkgs.vscode-extensions.github.copilot
      pkgs.vscode-extensions.tuttieee.emacs-mcx
      pkgs.vscode-extensions.golang.go
      pkgs.vscode-extensions.redhat.vscode-yaml
      pkgs.vscode-extensions.timonwong.shellcheck
      pkgs.vscode-extensions.tamasfe.even-better-toml
      pkgs.vscode-extensions.arcticicestudio.nord-visual-studio-code
    ];
  };

  systemd.user.startServices = true;
}
