# Syncthing configuration module.
#
# Usage:
#   imports = [ ./modules/syncthing.nix ];
#
# This is included by default in the main configuration (see home.nix).
# To disable, comment out the import line.
#
# Notes:
# - Runs as a systemd *user* service.
# - GUI is exposed only on 127.0.0.1:8384 (no password in this base config).
# - Logs go to a user-writable location (not /var/log, which would fail
#   for a user service on most systems).

{ config, ... }:

{
  services.syncthing = {
    enable = true;
    overrideDevices = false;
    overrideFolders = false;
    settings = {
      gui = {
        enabled = true;
        address = "127.0.0.1:8384";
        user = "admin";
        password = "";
      };
      options = {
        maxConcurrentDownloads = 20;
        maxConcurrentUploads = 10;
        urAccepted = -1;
      };
      log = {
        level = "info";
        # User-service safe path (journalctl -u syncthing also works).
        file = "${config.home.homeDirectory}/.local/share/syncthing/syncthing.log";
      };
    };
  };

  # Ensure the log/data directory exists for the user service.
  systemd.user.tmpfiles.rules = [
    "d %h/.local/share/syncthing - - - - -"
  ];
}
