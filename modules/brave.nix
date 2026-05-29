# Optional Brave browser configuration with heavy privacy hardening.
#
# Usage:
#   1. Add the nixgl channel (done automatically by install.sh when useGUI=true):
#        nix-channel --add https://github.com/nix-community/nixGL/archive/main.tar.gz nixgl
#        nix-channel --update
#
#   2. Import this module in your home.nix:
#        imports = [ ./modules/brave.nix ];
#
#   3. Rebuild with `home-manager switch`.
#
# This module applies the nixGL wrapper (for non-NixOS) and a long list of
# hardening flags + useful extensions. It is intentionally kept separate so
# it can be enabled on demand without cluttering the main configuration.

{ config, pkgs, ... }:

let
  # Only apply nixGL wrapper when the GUI toggle is enabled (matches install.sh behavior)
  useGUI = config.useGUI or false;
in
{
  programs.brave = {
    enable = true;

    package =
      if useGUI then
        let
          nixgl = import <nixgl> { };
          wrap =
            brave:
            pkgs.symlinkJoin {
              name = "brave";
              paths = [ brave ];
              nativeBuildInputs = [ pkgs.makeWrapper ];
              postBuild = ''
                mv $out/bin/brave $out/bin/.brave-unwrapped
                makeWrapper ${nixgl.auto.nixGLDefault}/bin/nixGL $out/bin/brave \
                  --add-flags "$out/bin/.brave-unwrapped"
                for f in $out/share/applications/*.desktop; do
                  substituteInPlace "$f" \
                    --replace-fail "Exec=${brave}/bin/brave" "Exec=brave"
                done
              '';
            };
        in
        (wrap pkgs.brave)
        // {
          override = args: wrap (pkgs.brave.override args);
        }
      else
        pkgs.brave;

    extensions = [
      "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
      "lckanjgmijmafbedllaakclkaicjfmnk" # clearurl
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # privacy badger
      "doojmbjmlfjjnbmnoijecmcbfeoakpjm" # noscript
      "oboonakemofpalcgghocfoadofidjkkk" # keepassxc
      "lcbjdhceifofjlpecfpeimnnphbcjgnc" # xbrowsersync
      "abehfkkfjlplnjadfcjiflnejblfmmpj" # nord theme
      "aleakchihdccplidncghkekgioiakgal" # h264ify
    ];

    commandLineArgs = [
      # --- shields & privacy ---
      "--disable-brave-rewards"
      "--disable-brave-wallet"
      "--disable-brave-ads"
      "--disable-brave-news"
      "--disable-brave-talk"
      "--disable-features=BraveLeo"
      "--disable-reading-from-canvas"
      "--disable-speech-api"
      "--force-webrtc-ip-handling-policy=disable-non-proxied-udp"
      "--ssl-version-min=tls1.2"
      "--dns-prefetch-disable"
      "--disable-preconnect"
      "--disable-sync"
      "--no-pings"
      "--no-referrers"

      # --- disable telemetry & experiments ---
      "--disable-breakpad-crash-handler"
      "--disable-component-update"
      "--disable-domain-reliability"
      "--disable-features=OptimizationHints,OptimizationHintsFetching,OptimizationTargetPrediction,ChromeWhatsNewUI,InterestFeedContentSuggestions,SignedExchangeSubresourcePrefetch,MediaEngagementBypassAutoplayPolicies,PreloadMediaEngagementData,AutofillServerCommunication"
      "--no-experiments"
      "--reset-variation-state"

      # --- block background noise ---
      "--disable-background-mode"
      "--disable-background-networking"

      # --- misc ---
      "--disable-translate"
      "--no-default-browser-check"

      # --- gpu ---
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"

      # --- perf ---
      "--enable-parallel-downloading"
      "--enable-lazy-image-loading"

      # --- display ---
      "--ozone-platform=x11"
      "--start-maximized"
    ];
  };
}
