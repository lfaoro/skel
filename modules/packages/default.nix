# Package groups for the skel configuration.
#
# This module (and its sub-files) defines all conditional and core packages.
#
# Import with:
#   imports = [ ./modules/packages ];
#
# Then reference via:
#   home.packages = with pkgs;
#     config.myPackages.gui
#     ++ config.myPackages.dev
#     ++ ...
#
# Toggles live in the gitignored `config.nix` (useDevTools, useGUI, etc.).

{ pkgs, lib, ... }:

let
  # Each category file exports its list under a key (dev, gui, network, etc.)
  dev = (import ./dev.nix { inherit pkgs; }).dev;
  gui = (import ./gui.nix { inherit pkgs; }).gui;
  network = (import ./network.nix { inherit pkgs; }).network;
  misc = (import ./misc.nix { inherit pkgs; }).misc;
  core = (import ./core.nix { inherit pkgs; }).core;
in
{
  options.myPackages = {
    dev = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
    gui = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
    network = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
    misc = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
    core = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
  };

  config.myPackages = {
    inherit
      dev
      gui
      network
      misc
      core
      ;
  };
}
