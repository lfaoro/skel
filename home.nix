# nix-store --verify --check-contents --repair
# https://nix-community.github.io/home-manager/options.html
{
  config,
  pkgs,
  lib,
  ...
}:

let
  nixGL = pkgs.callPackage <nixgl> { };
  # Wrap monero-gui with nixGLDefault
  monero-gui-wrapped = pkgs.writeShellScriptBin "monero-wallet-gui" ''
    ${nixGL.auto.nixGLDefault}/bin/nixGL ${pkgs.monero-gui}/bin/monero-wallet-gui "$@"
  '';

  configOpt = import ./config.nix;
  # dconf dump >file && dconf2nix file
  dconfModule = if configOpt.useDconf then [ ./dconf.nix ] else [ ];
  devTools =
    if configOpt.useDevTools then
      with pkgs;
      [
        go
        protobuf
        upx

        rustc
        cargo
        rust-analyzer
        rustfmt

        nodejs

        sqlite
        sqlint

        ttyd # terminal web sharing
        asciinema # terminal recorder
        asciinema-agg # gif from asciinema

        # live reload
        watchexec
        inotify-tools

        # formatters
        taplo # toml fmt
        black # python fmt
        nixfmt-rfc-style
        prettierd 
        harper # grammar

        # language servers
        nil
        bash-language-server
        yaml-language-server
        ansible-language-server
        shfmt
        vscode-langservers-extracted # html/js/css
        marksman # Markdown lsp
        # python312Packages.python-lsp-server
        # solc # solidity
        # terraform-ls
        # jsonnet-language-server
        # haskellPackages.language-protobuf
        # nodePackages_latest.bash-language-server
        # nodePackages.vue-language-server

        gitui
        lazygit
        gh # github CLI

        kubo # ipfs in Go

        # cloud
        cloudflared
        google-cloud-sdk
        awscli
        flyctl

        dive # look into docker image layers
        # podman
        # podman-tui # Terminal mgmt UI for Podman
        # passt # For Pasta rootless networking

        ## IaC
        # pulumi
        # terraform
        # ansible

      ]
    else
      [ ];

  guiPackages =
    if configOpt.useGUI then
      with pkgs;
      [
        # alacritty
        libcanberra-gtk3
        dconf-editor
        keepassxc
        monero-gui-wrapped
        qbittorrent
        telegram-desktop
        # nixGL.monero-gui
        # nixgl.tor-browser

        # nixGL.dbeaver-bin
        # nixGL.sqlitebrowser

        # nixGL.gimp
        # nixGL.imagemagick

        # nixGL.element-desktop
        # nixGL.hexchat
        # xmpp clients
        # nixGL.dino
        # nixGL.kaidan

        # gsettings editor
        # copyq
        # timeshift
        # chromium librewolf firefos.terraformx
        # nixGL.simplescreenrecorder
      ]
    else
      [ ];
in

{

  imports = dconfModule;

  home.username = configOpt.username;
  home.homeDirectory = configOpt.homedir;
  home.stateVersion = "24.11";
  home.keyboard.options = [ "caps:ctrl_modifier" ];
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  xdg.enable = true;
  xdg.mime.enable = true;
  fonts.fontconfig.enable = true;
  # xdg.configFile."fontconfig/fonts.conf".text = ''
  #     <?xml version="1.0"?>
  #     <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
  #     <fontconfig>
  #       <alias>
  #         <family>monospace</family>
  #         <prefer>
  #           <family>Hack Nerd Font</family>
  #           <family>Noto Color Emoji</family>
  #         </prefer>
  #       </alias>
  #     </fontconfig>
  #   '';

  # optimizations for non-NixOS distros
  targets.genericLinux.enable = true;

  home.packages =
    with pkgs;
    guiPackages
    ++ devTools
    ++ [
      # config
      helix # editor
      tmux # term multiplexer

      nix-info
      nix-tree
      nix-du
      dconf
      dconf2nix

      tldr
      zsh-completions
      jump
      
      coreutils
      inetutils
      nettools

      unzip
      gnupg
      age
      lynx
      exiftool

      sshpass # non-interactive SSH
      openssh_hpn
      gsocket

      yazi # file manager
      jq # json preview
      poppler # pdf preview
      ripgrep # grep
      fd # find
      zoxide # directory history
      xclip wl-clipboard xsel # clipboard

      # calculators
      kalker
      bc
      crunch

      lnav # logs
      profanity # irc
      elvish # shell

      # ranger nnn
      # parallel
      # nerdfonts

      # new generation
      dogdns # dig
      duf # du
      delta # diff
      meld # diff
      bat # cat
      glow # markdown in terminal
      eza # ls
      tokei # lines of code
      httpie # curl
      sd # sed
      ticker # stocks
      fim # framebuffer image viewer

      # monitoring
      htop
      ftop
      btop
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
      wget
      curl
      mosh
      rlwrap
      whois

      # ricing
      # nordic
      # nordzy-icon-theme
      # nordzy-cursor-theme
      neofetch

      speedtest-cli
      fast-cli
      yt-dlp

      magic-wormhole-rs

      # https://www.nerdfonts.com/font-downloads
      nerd-fonts.hack
      nerd-fonts.fira-code
      noto-fonts-color-emoji
    ];

  home.file = {
    ".config/alacritty".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/alacritty";
    ".config/yazi".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/yazi";
    ".config/gitui".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/gitui";
    ".config/ghostty".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/ghostty";
    ".tmux.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/tmux/.tmux.conf";
    ".config/helix".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/helix";
    ".config/aichat".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/aichat";
    ".config/htop".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/htop";
    ".config/lynx/lynx.cfg".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/lynx/lynx.cfg";
    ".config/lynx/lynx.lss".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/skel/lynx/lynx.lss";
  };

  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
    SUDO_EDITOR = "hx";

    PAGER = "bat";
    BAT_THEME = "Nord";
    # CASE_SENSITIVE="true";

    DOT = "$HOME/skel";
    NNN_PLUG = "f:finder;o:fzopen;p:mocq;d:diffs;t:nmount;v:imgview";
    WWW_HOME = "https://lite.duckduckgo.com/lite/?kae=d&kp=-2&kz=-1&kav=1&kaj=m&kau=-1&kaq=-1&kap=-1&kao=-1&kax=-1&kak=-1&kay=b&k1=-1&q=$1";
    LYNX_CFG = "$HOME/.config/lynx/lynx.cfg";
    LYNX_LSS = "$HOME/.config/lynx/lynx.lss";

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
  programs.zoxide = {
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
      core.editor = "hx";
      core.excludesfile = "${config.home.homeDirectory}/.gitignore_global"; # Global .gitignore file

      alias.co = "checkout";
      alias.br = "branch";
      alias.ci = "commit";
      alias.st = "status";
      alias.lg = "log --oneline --graph --decorate --all";

      color.ui = "auto";
      pull.rebase = "false"; # Merge (the default strategy)
      credential.helper = "cache --timeout=3600"; # Cache credentials for an hour
      push.default = "simple"; # Push the current branch to the corresponding upstream branch
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

    initContent = ''
      # source /etc/zshrc || true
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

      source "$HOME/skel/home/dotup.zsh" || :
      source "$HOME/skel/home/.aliasrc" || :
    '';

    shellAliases = {
      sudo = "sudo -i";

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
      grep = "rg";
      rg = "rg -uuui";
      calc = "kalker";
      fd = "fd -IH";
      duf = "duf --hide-fs tmpfs,devtmpfs";
      c = "cd";
      mm = "mkdir";

      clip = "xclip -sel c";
      copy = "xclip -sel c";
      pbcopy = "xclip -sel c";

      hm = "unset __HM_SESS_VARS_SOURCED ; home-manager";
      ip = "ip --color=auto";
      "'?'" = "duck";

      # mpv="gnome-session-inhibit mpv";
      tb = "nc termbin.com 9999";
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
      "--disable-brave-rewards"
      "--disable-features=WebRtcAllowInputVolumeAdjustment"
      "--disable-reading-from-canvas"
      "--ash-force-desktop"
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
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--enable-parallel-downloading"
      "--enable-quic"
      "--enable-lazy-image-loading"
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
    ];
  };

  programs.vscode = {
    enable = configOpt.useGUI;
    package = pkgs.vscodium;
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
          "nix-channel --update"
          "nix-store --gc"
          "nix-collect-garbage -d"
          "nix-store --optimise"
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
  services.syncthing = {
    enable = true;
    overrideDevices = false;
    overrideFolders = false;
  };
  services.syncthing.settings = {
    gui = {
      enabled = true;
      address = "127.0.0.1:8384";
      user = "admin";
      password = ""; # Use a secure password
    };
    options = {
      maxConcurrentDownloads = 20;
      maxConcurrentUploads = 10;
      urAccepted = -1;
    };
    log = {
      level = "info";
      file = "/var/log/syncthing.log";
    };
    # folders = {
    #     "work-folder" = {
    #       id = "work";  # Unique ID for the folder
    #       path = "~/work";  # Correctly reference the home directory
    #       type = "sendreceive";  # Folder type
    #       # devices = [ "device-id-1", "device-id-2" ];  # List of devices to share with
    #       # Additional options can be added here
    #     };
    #   };
  };

}
