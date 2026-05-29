#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

ok()  { echo -e "${GREEN}[ OK ]${NC} $*"; }
skip(){ echo -e "${YELLOW}[SKIP]${NC} $*"; }

echo 'b08dfa6083e7567a1921a715000001fb' | sudo tee /etc/machine-id >/dev/null
ok "/etc/machine-id randomized"

if command -v NetworkManager &>/dev/null; then
  sudo mkdir -p /etc/NetworkManager/conf.d
  FILE="/etc/NetworkManager/conf.d/00-macrandomize.conf"
  if ! test -f "$FILE"; then
    cat <<EOF | sudo tee "$FILE" >/dev/null
[device]
wifi.scan-rand-mac-address=yes
[connection]
wifi.cloned-mac-address=random
ethernet.cloned-mac-address=random
EOF
    sudo systemctl restart NetworkManager
    ok "NetworkManager: MAC randomization"
  else
    skip "NetworkManager: MAC randomization already set"
  fi
else
  skip "NetworkManager not installed"
fi

sudo hostnamectl hostname "localhost"
ok "hostname set to localhost"

sudo sed -i 's/UMASK 022/UMASK 077/g' /etc/login.defs
ok "login umask: 022 → 077"

sudo chmod 755 /etc/apt/sources.list.d
ok "/etc/apt/sources.list.d permissions"

if [[ -f /etc/systemd/resolved.conf ]]; then
  dnsSec=$(grep -c '^DNSSEC=' /etc/systemd/resolved.conf || true)
  llmnr=$(grep -c '^LLMNR=no' /etc/systemd/resolved.conf || true)
  if [[ "$dnsSec" -eq 0 ]] || [[ "$llmnr" -eq 0 ]]; then
    [[ "$dnsSec" -eq 0 ]] && echo 'DNSSEC=allow-downgrade' | sudo tee -a /etc/systemd/resolved.conf >/dev/null
    [[ "$llmnr" -eq 0 ]] && echo 'LLMNR=no' | sudo tee -a /etc/systemd/resolved.conf >/dev/null
    sudo systemctl restart systemd-resolved || :
    ok "resolved.conf: DNSSEC enabled, LLMNR disabled"
  else
    skip "resolved.conf: already configured"
  fi
else
  skip "/etc/systemd/resolved.conf not found"
fi

# ── Telemetry & phoning home ──────────────────────────────────────────
ok "kerneloops disabled"
sudo systemctl disable --now kerneloops || :

sudo apt purge -y -qq apport
ok "apport purged"

sudo apt purge -y -qq ubuntu-report
ok "ubuntu-report purged"

sudo apt purge -y -qq whoopsie
ok "whoopsie purged"

sudo apt purge -y -qq zeitgeist-core zeitgeist-datahub
ok "zeitgeist purged"

sudo apt purge -y -qq ubuntu-advantage-tools
ok "ubuntu-advantage-tools purged"

sudo apt purge -y -qq network-manager-config-connectivity-ubuntu
ok "network-manager-config-connectivity-ubuntu purged"

if command -v NetworkManager &>/dev/null; then
  sudo touch /etc/NetworkManager/conf.d/20-connectivity-ubuntu.conf
  ok "NetworkManager: connectivity check disabled"
fi
if [[ -f /etc/default/motd-news ]]; then
  sudo sed -i 's/ENABLED=1/ENABLED=0/' /etc/default/motd-news
  ok "motd-news disabled"
else
  skip "/etc/default/motd-news not found"
fi

# ── GNOME location tracking ───────────────────────────────────────────
if systemctl list-unit-files geoclue.service &>/dev/null; then
  sudo systemctl disable geoclue
  sudo systemctl mask geoclue
  sudo systemctl status geoclue || :
  ok "geoclue disabled + masked"
else
  skip "geoclue not installed"
fi

# ── NTP ────────────────────────────────────────────────────────────────
if [[ -f /etc/systemd/timesyncd.conf ]]; then
  ntpSec=$(grep -c '^NTP=' /etc/systemd/timesyncd.conf || true)
  if [[ "$ntpSec" -eq 0 ]]; then
    cat <<EOF | sudo tee -a /etc/systemd/timesyncd.conf >/dev/null
[Time]
NTP=0.europe.pool.ntp.org
FallbackNTP=3.europe.pool.ntp.org
EOF
    sudo systemctl restart systemd-timesyncd
    ok "timesyncd: NTP configured"
  else
    skip "timesyncd: NTP already configured"
  fi
else
  skip "/etc/systemd/timesyncd.conf not found"
fi

# ── Sysctl hardening ───────────────────────────────────────────────────
sudo tee /etc/sysctl.d/99-privacy.conf >/dev/null <<EOF
net.ipv6.conf.all.use_tempaddr=2
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.all.log_martians=1
net.ipv4.conf.all.accept_source_route=0
net.ipv4.tcp_syncookies=1
kernel.kptr_restrict=2
kernel.dmesg_restrict=1
kernel.core_pattern=|/bin/false
fs.suid_dumpable=0
EOF
sudo sysctl -p /etc/sysctl.d/99-privacy.conf
ok "sysctl hardening applied (11 params)"

# ── Disable broadcast services ─────────────────────────────────────────
ok "avahi-daemon disabled"
sudo systemctl disable --now avahi-daemon || :
ok "cups-browsed disabled"
sudo systemctl disable --now cups-browsed || :

# ── Bluetooth ─────────────────────────────────────────────────────────
if [[ -f /etc/bluetooth/main.conf ]]; then
  if grep -q 'AutoEnable=true' /etc/bluetooth/main.conf; then
    sudo sed -i 's/AutoEnable=true/AutoEnable=false/' /etc/bluetooth/main.conf
    ok "Bluetooth: AutoEnable off"
  else
    skip "Bluetooth: AutoEnable already off"
  fi
else
  skip "Bluetooth not installed"
fi

# ── Disable unattended-upgrades timer ─────────────────────────────────
ok "apt-daily timers disabled"
sudo systemctl disable --now apt-daily.timer apt-daily-upgrade.timer || :
