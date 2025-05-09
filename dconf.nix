# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

let
  configOpt = import ./config.nix;
in
{
  dconf.settings = {
    "apps/update-manager" = {
      first-run = false;
      launch-count = 16;
      launch-time = mkInt64 1690540585;
      show-details = true;
      window-height = 400;
      window-width = 593;
    };

    "ca/desrt/dconf-editor" = {
      saved-pathbar-path = "/org/gnome/desktop/background/primary-color";
      saved-view = "/org/gnome/desktop/background/primary-color";
      show-warning = false;
      window-height = 500;
      window-is-maximized = false;
      window-width = 540;
    };

    "com/ubuntu/update-notifier" = {
      regular-auto-launch-interval = 14;
      release-check-time = mkUint32 1690739393;
    };

    "org/gnome/calculator" = {
      accuracy = 9;
      angle-units = "degrees";
      base = 10;
      button-mode = "basic";
      number-format = "automatic";
      show-thousands = false;
      show-zeroes = false;
      source-currency = "DZD";
      source-units = "degree";
      target-currency = "DZD";
      target-units = "radian";
      window-position = mkTuple [
        26
        23
      ];
      word-size = 64;
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "vertical";
      picture-opacity = 5;
      picture-options = "none";
      picture-uri = "none";
      picture-uri-dark = "none";
      primary-color = "#292C33";
      secondary-color = "#434854";
    };

    "org/gnome/desktop/calendar" = {
      show-weekdate = true;
    };

    "org/gnome/desktop/input-sources" = {
      per-window = false;
      sources = [
        (mkTuple [
          "xkb"
          "us"
        ])
      ];
      xkb-options = [
        "ctrl:nocaps"
      ] ++ (if configOpt.swapAltWin then [ "altwin:swap_alt_win" ] else [ ]);
    };

    "org/gnome/desktop/interface" = {
      clock-show-seconds = false;
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      font-hinting = "slight";
      gtk-key-theme = "Emacs";
      # gtk-theme = "Nordic";
      # icon-theme = "Nordzy";
      show-battery-percentage = true;
    };

    "org/gnome/desktop/lockdown" = {
      disable-lock-screen = false;
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      delay = mkUint32 232;
      repeat-interval = mkUint32 32;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "adaptive";
      natural-scroll = true;
      speed = -0.20588235294117652;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      click-method = "fingers";
      speed = 0.4558823529411764;
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/privacy" = {
      recent-files-max-age = 1;
      remember-recent-files = false;
      remove-old-temp-files = true;
      remove-old-trash-files = true;
    };

    "org/gnome/desktop/search-providers" = {
      disable-external = true;
      sort-order = [
        "org.gnome.Contacts.desktop"
        "org.gnome.Documents.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 600;
    };

    "org/gnome/desktop/sound" = {
      allow-volume-above-100-percent = true;
      event-sounds = true;
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-group = [ "<Super>grave" ];
      switch-group-backward = [ "<Shift><Super>grave" ];
    };

    "org/gnome/desktop/wm/preferences" = {
      theme = "Nordic";
    };

    "org/gnome/gedit/preferences/editor" = {
      scheme = "Yaru-dark";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      idle-dim = false;
      power-button-action = "suspend";
      power-saver-profile-on-low-batter = true;
      sleep-inactive-ac-timeout = 7200;
      sleep-inactive-ac-type = "suspend";
      sleep-inactive-battery-type = "suspend";
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-fixed = false;
      dock-position = "RIGHT";
      extend-height = false;
      show-mounts-network = false;
      show-mounts-only-mounted = true;
    };

    "org/gnome/system/location" = {
      enabled = false;
    };

    "org/nemo/preferences" = {
      show-location-entry = true;
    };

  };
}
