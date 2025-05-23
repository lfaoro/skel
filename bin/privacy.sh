#!/usr/bin/bash
# some simple anonymity/privacy settings every linux user should implement
set -ex
# trap 'read -p "run: $BASH_COMMAND"' DEBUG

# anon machine-id to look like any whomix user
echo 'b08dfa6083e7567a1921a715000001fb' | sudo tee /etc/machine-id && cat /etc/machine-id

# randomize MAC address
FILE="/etc/NetworkManager/conf.d/00-macrandomize.conf"
if ! test -f "$FILE"; then
	cat <<EOF | sudo tee "$FILE"
[device]
wifi.scan-rand-mac-address=yes
[connection]
wifi.cloned-mac-address=random
ethernet.cloned-mac-address=random
EOF

	sudo systemctl restart NetworkManager
	sudo hostnamectl hostname "localhost"

	# u=rwx,g=,o= for new files
	sudo sed -i 's/UMASK 022/UMASK 077/g' /etc/login.defs
	# let's not have apt break
	sudo chmod 644 /etc/apt/sources.list.d
fi

dnsSec=$(grep -c DNSSEC=yes /etc/systemd/resolved.conf)
if [[ "$dnsSec" -eq 0 ]]; then
	echo 'DNSSEC=yes' | sudo tee -a /etc/systemd/resolved.conf
	sudo systemctl restart systemd-resolved || :
fi

# disable this shitty gnome location tracking feature
sudo systemctl disable geoclue
sudo systemctl mask geoclue
sudo systemctl status geoclue || :

# remove crash reporting
sudo apt purge apport
# remove conn check to ubuntu
sudo apt purge network-manager-config-connectivity-ubuntu
sudo touch /etc/NetworkManager/conf.d/20-connectivity-ubuntu.conf

# get rid of canonical NTP
# https://www.ntppool.org/
cat <<EOF | sudo tee /etc/systemd/timesyncd.conf
[Time]
NTP=0.europe.pool.ntp.org
FallbackNTP=3.europe.pool.ntp.org
EOF
sudo systemctl restart systemd-timesyncd

# remove scopes and lens
# dpkg -l |rg -i "scope|lens" |cut -d' ' -f3 |sudo apt remove
