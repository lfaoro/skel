# Development tools and language servers.
# Enabled via config.nix: useDevTools = true;

{ pkgs, ... }:

let
  configOpt = import ../../config.nix;
in
{
  dev =
    if configOpt.useDevTools then
      with pkgs;
      [
        (go-bin.latestStable.withDefaultTools) # Go + version-locked gopls, dlv, golangci-lint, staticcheck, gofumpt, govulncheck
        protoc-gen-go # Standalone Go tools (Go-version independent; prebuilt from nixpkgs)
        protoc-gen-go-grpc
        protoc-gen-connect-go
        protoc-gen-doc
        buf
        grpcurl
        ghz
        sqlc
        air
        goreleaser
        scc
        nix-search-cli
        vhs
        protobuf # Protocol Buffers compiler
        upx # executable packer
        postgresql # PostgreSQL database

        rustc # Rust compiler
        cargo # Rust package manager
        rust-analyzer # Rust LSP
        rustfmt # Rust formatter
        zig # Zig compiler
        cloc # count lines of code

        nodejs # Node.js runtime
        mise # dev environment manager
        sqlite # lightweight SQL database

        ttyd # share terminal over web
        asciinema # terminal session recorder
        asciinema-agg # gif from asciinema

        watchexec # watch files, exec command
        inotify-tools # filesystem event monitor

        taplo # TOML formatter
        black # Python formatter
        prettierd # JS/TS/CSS/JSON formatter
        harper # grammar checker

        hadolint # Dockerfile linter
        actionlint # GitHub Actions linter
        codespell # code spell checker
        lychee # link checker
        editorconfig-checker # editorconfig validator
        trivy # vulnerability scanner
        grex # regex generator

        nil # Nix LSP
        bash-language-server # Bash LSP
        yaml-language-server # YAML LSP
        shfmt # shell formatter
        zls # Zig LSP
        vscode-langservers-extracted # HTML/JS/CSS/JSON LSP
        marksman # Markdown LSP
        typescript-language-server # TypeScript LSP

        gotests # generate Go tests
        impl # generate Go interface implementations
        lazygit # terminal Git UI
        gh # GitHub CLI

        kubo # IPFS in Go

        cloudflared # Cloudflare Tunnel
        flyctl # Fly.io CLI

        dive # inspect Docker image layers
        gitlab-runner # CI/CD runner

        minisign # signed signatures
        signify # OpenBSD signed signatures
        styx # static site generator

        tealdeer # fast tldr client
        tokei # lines of code counter
        hyperfine # command benchmarking
        httpie # HTTP client
        sd # sed alternative
        hexyl # hex viewer
        glow # markdown reader
        jless # interactive JSON viewer
        poppler # PDF rendering
        exiftool # metadata editor
        lnav # log file navigator
        doggo # modern dig
        gocryptfs # encrypted filesystem
        pandoc # document converter
        systemctl-tui # systemd TUI manager

        nix-info # Nix info tool
        nix-tree # Nix dependency browser
        nix-du # Nix store disk usage
        nix-diff # diff Nix closures
        nix-output-monitor # pretty Nix build output
        nurl # generate Nix fetch expressions
        dconf # dconf CLI
        dconf2nix # convert dconf dump to Nix
      ]
    else
      [ ];
}
