# Network scanning and analysis tools.
# Enabled via config.nix: useNetworkTools = true;

{ pkgs, ... }:

let
  configOpt = import ../../config.nix;
in
{
  network =
    if configOpt.useNetworkTools then
      with pkgs;
      [
        nmap # network scanner
        zmap # fast internet scanner
        masscan # fast port scanner
        rustscan # fast port scanner
        tshark # terminal wireshark
        termshark # terminal wireshark
        netcat # TCP/UDP swiss army knife
        socat # socket relay
        websocat # WebSocket relay
        iftop # bandwidth monitor
        nethogs # per-process network monitor
        crunch # wordlist generator
        ipcalc # IP calculator
        inetutils # network utilities (telnet, ftp)
        nettools # net-tools (ifconfig, netstat)
      ]
    else
      [ ];
}
