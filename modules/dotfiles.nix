# Dotfile symlink management.
#
# This module handles symlinking configuration directories from
# ~/skel/dotfiles into the user's home directory using out-of-store
# symlinks (so changes in the repo take effect immediately without
# a home-manager switch).
#
# Usage:
#   imports = [ ./modules/dotfiles.nix ];
#
# To add a new symlink, edit the dotfileMap below.

{ config, lib, ... }:

let
  skelRoot = "${config.home.homeDirectory}/skel";

  symlinkDot = _: skelPath: {
    source = config.lib.file.mkOutOfStoreSymlink "${skelRoot}/${skelPath}";
  };

  dotfileMap = {
    ".config/alacritty" = "dotfiles/alacritty";
    ".config/yazi" = "dotfiles/yazi";
    ".config/lazygit" = "dotfiles/lazygit";
    ".config/ghostty" = "dotfiles/ghostty";
    ".config/rmpc" = "dotfiles/rmpc";
    ".config/helix" = "dotfiles/helix";
    ".config/htop" = "dotfiles/htop";
    ".config/tridactyl/tridactylrc" = "dotfiles/tridactyl/tridactylrc";
    ".config/lynx/lynx.cfg" = "dotfiles/lynx/lynx.cfg";
    ".config/lynx/lynx.lss" = "dotfiles/lynx/lynx.lss";
    ".tmux.conf" = "dotfiles/tmux/.tmux.conf";
    ".local/bin/duck" = "dotfiles/lynx/duck";
    ".local/bin/sgh" = "dotfiles/lynx/sgh";
    ".local/bin/snixpkg" = "dotfiles/lynx/snixpkg";
  };
in
{
  home.file = lib.mapAttrs symlinkDot dotfileMap;
}
