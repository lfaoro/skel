#!/usr/bin/env bash
# Remap Caps Lock to Ctrl system-wide (TTY + X11 + Wayland)
set -ex

FILE="/etc/default/keyboard"

if grep -q '^XKBOPTIONS=' "$FILE"; then
	sudo sed -i 's/^XKBOPTIONS=.*/XKBOPTIONS="ctrl:nocaps"/' "$FILE"
else
	echo 'XKBOPTIONS="ctrl:nocaps"' | sudo tee -a "$FILE"
fi

sudo setupcon

echo "Caps Lock -> Ctrl applied system-wide"
