# Miscellaneous CLI tools.
# Enabled via config.nix: useMisc = true;

{ pkgs, ... }:

let
  configOpt = import ../../config.nix;
in
{
  misc =
    if configOpt.useMisc then
      with pkgs;
      [
        jump # jump to directories
        elvish # expressive shell
        profanity # terminal XMPP client
        ticker # terminal stock ticker
        kalker # calculator
        bc # arbitrary precision calculator
        fim # framebuffer image viewer
        lynx # terminal web browser
        sshpass # non-interactive SSH password
        gsocket # global socket relay
        speedtest-cli # internet speed test
        magic-wormhole-rs # secure file transfer
        monero-cli # Monero CLI wallet
        unzip # extract zip archives
        imagemagick_light # image manipulation
      ]
    else
      [ ];
}
