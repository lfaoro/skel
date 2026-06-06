{
  pkgs,
  config,
  ...
}:

{
  systemd.user.services.osqueryd = {
    Unit = {
      Description = "osquery daemon";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${pkgs.osquery}/bin/osqueryd --config_path %h/.config/osquery/osquery.conf --database_path %h/.local/share/osquery/db/osquery.db --pidfile %h/.local/share/osquery/osqueryd.pidfile --extensions_socket %h/.local/share/osquery/osquery.em";
      Restart = "on-failure";
      RestartSec = "30";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.osquery-alert = {
    Unit = {
      Description = "osquery alert checker";
      After = [ "osqueryd.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "%h/.config/osquery/alert.sh";
    };
  };

  systemd.user.timers.osquery-alert = {
    Unit = {
      Description = "Run osquery alert check";
    };
    Timer = {
      OnUnitActiveSec = "5m";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/sync/music";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire"
      }
    '';
  };

  systemd.user.tmpfiles.rules = [
    "d %h/.local/share/osquery/log - - - - -"
    "d %h/.local/share/osquery/db - - - - -"
    "d %h/sync/music - - - - -"
  ];
}
