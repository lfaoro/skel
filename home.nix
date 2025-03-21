# nix-store --verify --check-contents --repair
# https://nix-community.github.io/home-manager/options.html
{ lib, config, pkgs, ... }:

let 
   nixGL = import <nixgl> { };
  nixGLWrap = pkg: 
    pkgs.buildEnv {
      name = "nixGL-${pkg.name}";
      paths = [pkg] ++ (map (bin: pkgs.hiPrio (
        pkgs.writeShellScriptBin bin ''
          exec -a "$0" "${nixGL.auto.nixGLDefault}/bin/nixGL" "${pkg}/bin/${bin}" "$@"
        ''
      )) (builtins.attrNames (builtins.readDir "${pkg}/bin")));
    };
  configOpt = import ./config.nix;

  # dconf dump >file && dconf2nix file
  dconfModule = if configOpt.useDconf then [./dconf.nix] else [];

  devTools = if configOpt.useDevTools then with pkgs; [
    go
    protobuf

    rustc
    cargo
    rust-analyzer
    rustfmt

    sqlite sqlint

    # live reload
    watchexec
    inotify-tools

    # formatters
    taplo # toml fmt
    black # python fmt
    nixfmt-rfc-style 

    # language servers
    nil
    python312Packages.python-lsp-server
    vscode-langservers-extracted # html/js/css
    marksman # Markdown lsp
    # solc # solidity 
    # terraform-ls
    # nodePackages_latest.yaml-language-server
    # jsonnet-language-server
    # haskellPackages.language-protobuf
    # nodePackages_latest.bash-language-server
    # nodePackages.vue-language-server

    gitui lazygit
    gh # github CLI

    kubo # ipfs in Go

    # cloud
    # cloudflared
    # gcloud
    # aws
     
    ## IaC
    # pulumi
    # terraform
    # ansible

   ] else [];

  guiPackages = if configOpt.useGUI then with pkgs; [
    # GUI
    # alacritty
    keepassxc
    dbeaver-bin
    tor-browser
    sqlitebrowser
    gimp imagemagick

    # monero-gui

    telegram-desktop element-desktop hexchat 
    dino kaidan # xmpp clients

    # ffmpeg mpv vlc 
    dconf-editor # gsettings editor
    # copyq
    # timeshift
    # chromium librewolf firefos.terraformx
    simplescreenrecorder
   ] else [];
 in
{
  imports = dconfModule;

  home.username = configOpt.username;
  home.homeDirectory = configOpt.homedir;
  home.stateVersion = "24.11";
  home.keyboard.options = [ "caps:ctrl_modifier" ];
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  xdg.enable=true;
  xdg.mime.enable=true;
  fonts.fontconfig.enable = true;
  # optimizations for non-NixOS distros
  targets.genericLinux.enable = true;

  home.packages = with pkgs; guiPackages ++ devTools ++ [
    # config
    nix-info
    nix-tree
    nix-du

    zsh-completions
    dconf2nix
    dconf
    tmux
    jump
    xclip xsel
    coreutils
    unzip
    gnupg age
    helix # editor

    # calculators
    kalker bc crunch
    lnav # logs
    profanity # irc
    elvish # shell

    # ranger nnn
    # parallel
    # nerdfonts

    # new generation
    dogdns # dig
    ripgrep # grep
    fd # find
    duf # du
    delta meld # diff
    bat # cat
    eza # ls
    tokei # lines of code
    httpie # curl
    sd # sed
    ticker # stocks
    fim # framebuffer image viewer
    
    # monitoring
    htop ftop btop
    nethogs
    tshark

    # disks
    ncdu
    broot
    # udisks

    # network
    ipcalc
    nmap
    zmap
    masscan
    rustscan
    # dbus-map
    netcat
    socat
    websocat
    iftop
    lsof
    wget curl jq
    mosh rlwrap
    whois

    # ricing
    # nordic
    # nordzy-icon-theme
    # nordzy-cursor-theme
    neofetch

    # fast-cli
    speedtest-cli
    magic-wormhole-rs
    yt-dlp

    # crypto
    # monero-cli

    # fonts
    fira-code fira-code-symbols
    hack-font
  ];

  home.file = {
    ".config/alacritty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/alacritty";
    ".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/tmux/.tmux.conf";
    ".config/helix".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/helix";

    ".config/htop".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/htop";
    ".config/lynx/lynx.cfg".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/lynx/lynx.cfg";
    ".config/lynx/lynx.lss".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/lynx/lynx.lss";

    ".bashrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/home/.bashrc";
    ".aliasrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/home/.aliasrc";
  };

  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
    SUDO_EDITOR = "hx";

    PAGER = "bat -p";
    BAT_THEME="Nord";
    # CASE_SENSITIVE="true";

    DOT = "$HOME/skel";
    NNN_PLUG = "f:finder;o:fzopen;p:mocq;d:diffs;t:nmount;v:imgview";
    WWW_HOME = "https://lite.duckduckgo.com/lite/?kae=d&kp=-2&kz=-1&kav=1&kaj=m&kau=-1&kaq=-1&kap=-1&kao=-1&kax=-1&kak=-1&kay=b&k1=-1&q=$1";
    LYNX_CFG="$HOME/.config/lynx/lynx.cfg";
    LYNX_LSS="$HOME/.config/lynx/lynx.lss";

    LANG = "en_US.UTF-8";
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  home.sessionPath = [
    "$HOME/skel/bin"
    "$HOME/go/bin"
    "$HOME/.cargo/bin"
    "/usr/local/go/bin"
    "$HOME/.local/bin"
  ];

  programs.direnv.enable = true;
  programs.command-not-found.enable = true;
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.git = {
    enable = true;
    userName = "user";
    userEmail = "user@example.com";
    signing = {
      key = "E07A93374443E5CB";
      signByDefault = false;
    };

    extraConfig = {
      # Core settings
      core.editor = "hx";  # Set your preferred editor (e.g., vim, nvim, nano)
      core.excludesfile = "${config.home.homeDirectory}/.gitignore_global";  # Global .gitignore file

      alias.co = "checkout";
      alias.br = "branch";
      alias.ci = "commit";
      alias.st = "status";
      alias.lg = "log --oneline --graph --decorate --all";

      color.ui = "auto";

      pull.rebase = "false";  # Merge (the default strategy)
      
      credential.helper = "cache --timeout=3600";  # Cache credentials for an hour
      
      push.default = "simple";  # Push the current branch to the corresponding upstream branch
    };
  };
   # Global .gitignore file
  xdg.configFile."git/ignore".text = ''
    # Compiled source #
    ###################
    *.com
    *.class
    *.dll
    *.exe
    *.o
    *.so

    # Packages #
    ############
    # it's better to unpack these files and commit the raw source
    *.7z
    *.dmg
    *.gz
    *.iso
    *.jar
    *.rar
    *.tar
    *.zip

    # Logs and databases #
    ######################
    *.log
    *.sql
    *.sqlite

    # OS generated files #
    ######################
    .DS_Store
    .DS_Store?
    Thumbs.db
    ehthumbs.db
    Desktop.ini
    .Spotlight-V100
    .Trashes
    ._.DS_Store
    ._*
  '';

  # zplug = {
  #   enable = true;
  #   plugins = [
  #     { name = "zsh-users/zsh-autosuggestions"; }
  #     { name = "zsh-users/zsh-syntax-highlighting"; }
  #     { name = "zdharma-continuum/fast-syntax-highlighting"; }
  #     { name = "sobolevn/wakatime-zsh-plugin"; }
  #     { name = "marlonrichert/zsh-autocomplete"; tags = [ depth:1 ]; }
  #   ];
  # };

  # https://reasoniamhere.com/2014/01/11/outrageously-useful-tips-to-master-your-z-shell/
  # https://strcat.de/zsh/#tipps
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = false;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "emacs";
    # enableBashCompletion = true; seems not supported atm
    # enableGlobalCompInit = true;

    history = {
      size = 10000;
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };
    

    # home.sessionPath doesn't work atm, this is a workaround.
    # https://github.com/nix-community/home-manager/issues/2991
    profileExtra = lib.optionalString (config.home.sessionPath != [ ]) ''
      export PATH="$PATH''${PATH:+:}${lib.concatStringsSep ":" config.home.sessionPath}"
    '';

    initExtraFirst = ''
      source /etc/zshrc || true
      source "$HOME/.aliasrc" || :
      source "$HOME/.sec/keys" || :

      # disable tty flow control XOFF/XON
      # https://en.wikipedia.org/wiki/Software_flow_control
      stty -ixon

      if [[ -e $(which jump) ]]; then
          eval "$(jump shell zsh)"
      fi

      autoload -Uz compinit && compinit
      #zstyle ":completion:*" matcher-list "" "m:{a-zA-Z}={A-Za-z}" "r:|=*" "l:|=* r:|=*"
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

      PROMPT="%(?.%F{green}√.%F{red}?)%f %n %B%F{240}%2~%f%b > ";
    '';

    initExtra = ''
      source "$HOME/skel/home/dotup.zsh" || :
    '';


   shellAliases = {
      gs = "git status";
      gc = "git commit -m";
      ga = "git add";
      gd = "git diff --unified=5 --diff-filter=M";
      gp = "git push";
      gpu = "git pull";
      gl = "git log --stat";
      gcp = "git add . && git commit -m 'update' && git push";
      gacp = "git add . && git commit -m 'update' && git push";
      gac = "git add . && git commit -m 'update' && git push";

      ls = "exa";
      l = "exa -as modified --group-directories-first";
      ll = "exa --git -lahgs modified --group-directories-first -s extension";
      t = "exa --tree --level=2";
      tt = "exa --tree --level=4";
      ttt = "exa --tree --level=6";
      cat = "bat -p";
      grep = "rg";
      rg = "rg -uuui";
      calc = "kalker";
      fd = "fd -IH";
      duf = "duf --hide-fs tmpfs,devtmpfs";
      ping = "ping -B";
      c = "cd";
      mm = "mkdir";

      clip="xclip -sel c";
      k="kubectl";
      hm="unset __HM_SESS_VARS_SOURCED ; home-manager";
      ip="ip --color=auto";
      "'?'"="duck";

      # mpv="gnome-session-inhibit mpv";
      tb="nc termbin.com 9999";
    };
  };

  programs.brave = {
    enable = configOpt.useGUI;
    # settings = {
    #   "ad_block" = true;
    #   "fingerprinting_protection" = "strict";
    #   "https_only_mode_enabled" = true;
    #   "tracking_protection_mode" = "strict";
    #   "strict_site_isolation" = true;
    #   "safe_browsing_enabled" = true;
    # };
    extensions = [
      "dbepggeogbaibhgnhhndojpepiihcmeb" # vinium
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
      "lckanjgmijmafbedllaakclkaicjfmnk" # clearurl
      "edibdbjcniadpccecjdfdjjppcpchdlm" # don't care about cookies
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # privacy badger
      "doojmbjmlfjjnbmnoijecmcbfeoakpjm" # noscript
      "oboonakemofpalcgghocfoadofidjkkk" # keepassxc
      "lcbjdhceifofjlpecfpeimnnphbcjgnc" # xbrowsersync
      "abehfkkfjlplnjadfcjiflnejblfmmpj" # nord theme
      "aleakchihdccplidncghkekgioiakgal" # h264ify
      "nkbihfbeogaeaoehlefnkodbefgpgknn" # metamask
    ];
    commandLineArgs = [
      "--disable-features=WebRtcAllowInputVolumeAdjustment"
      "--disable-reading-from-canvas"
      "--ash-force-desktop"
      # "--disable-3d-apis"
      "--disable-background-mode"
      "--disable-plugins-discovery"
      "--disable-preconnect"
      "--disable-translate"
      "--dns-prefetch-disable"
      "--enable-kiosk-mode"
      "--media-cache-size"
      "--multi-profiles"
      "--new-profile-management"
      "--no-experiments"
      "--no-pings"
      "--no-referrers"
      "--purge-memory-button"
      "--restore-last-session"
      "--reset-variation-state"
      "--ssl-version-min"
      "--start-maximized"
      # "--disable-webgl"
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      # "--disable-features=UseSkiaRenderer"
      "--enable-parallel-downloading"
      "--enable-quic"
      "--enable-lazy-image-loading"
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
    ];
  };

  programs.vscode = {
    enable = configOpt.useGUI ;
    package = pkgs.vscodium;
    userSettings = {
    };
    extensions = [
      pkgs.vscode-extensions.github.copilot
      pkgs.vscode-extensions.tuttieee.emacs-mcx
      pkgs.vscode-extensions.golang.go
      pkgs.vscode-extensions.redhat.vscode-yaml
      pkgs.vscode-extensions.timonwong.shellcheck
      pkgs.vscode-extensions.tamasfe.even-better-toml
      pkgs.vscode-extensions.arcticicestudio.nord-visual-studio-code
    ];
  };


#dpkg-query --show 'linux-modules-*' |cut -f1 |grep -v $(uname -r) |xargs apt remove"
  systemd.user.services = {
    cronjobs = {
      Unit = {
        Description = "cronjobs";
      };
      Service = {
        Type = "oneshot";
        ExecStart = [ 
          "/usr/bin/journalctl --vacuum-time=7d" 
          "/nix/var/nix/profiles/default/bin/nix-channel --update"
          "/nix/var/nix/profiles/default/bin/nix-store --gc"
      	  "/nix/var/nix/profiles/default/bin/nix-collect-garbage -d"
      	  "/nix/var/nix/profiles/default/bin/nix-store --optimise"
        ];
      };
    };
  };

  systemd.user.timers = {
    cronjobs = {
      Unit = {
        Description = "cronjobs";
      };
      Timer = {
        # https://silentlad.com/systemd-timers-oncalendar-(cron)-format-explained
        # OnCalendar = "weekly";
        OnCalendar = "daily";
        Persistent = true;
        Unit = "cronjobs.service";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };

  # Define mosh as a user service
  systemd.user.services.mosh = {
    Unit = {
      Description = "Mosh server service";
    };

    Service = {
      ExecStart = "${pkgs.mosh}/bin/mosh-server";
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "10s";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.startServices = true; # This enables all systemd.user.services to start
}
