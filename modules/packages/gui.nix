# GUI applications.
# Enabled via config.nix: useGUI = true;

{ pkgs, ... }:

let
  configOpt = import ../../config.nix;
in
{
  gui =
    if configOpt.useGUI then
      with pkgs;
      [
        # alacritty # GPU-accelerated terminal
        # ghostty # GPU-accelerated terminal
        libcanberra-gtk3 # GTK sound event wrapper
        dconf-editor # dconf settings GUI
        keepassxc # password manager
        qbittorrent # BitTorrent client
        telegram-desktop # Telegram messenger
        monero-gui # Monero wallet
        # feather # Monero desktop wallet
        bruno # API client
        meld # visual diff/merge tool
        brave # Brave browser (policy installed by bin/install.sh when GUI)
      ]
    else
      [ ];
}
