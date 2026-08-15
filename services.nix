{ config, ... }:

{
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
    "d %h/sync/music - - - - -"
  ];
}
