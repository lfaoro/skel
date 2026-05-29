#!/usr/bin/env bash
# Toggle Alt ↔ Win key swap system-wide
set -eo pipefail

FILE="/etc/default/keyboard"
OPT="altwin:swap_alt_win"

if [[ ! -f "$FILE" ]]; then
	echo "ERROR: $FILE not found"
	exit 1
fi

current=$(grep '^XKBOPTIONS=' "$FILE" | sed 's/XKBOPTIONS=//;s/"//g')

if echo "$current" | grep -q "$OPT"; then
	# Remove the option
	new=$(echo "$current" | sed "s/,$OPT//;s/$OPT,//;s/,,/,/")
	sudo sed -i "s|^XKBOPTIONS=.*|XKBOPTIONS=\"$new\"|" "$FILE"
	echo "Alt/Win swap: DISABLED"
else
	# Add the option
	if [[ -z "$current" ]]; then
		new="$OPT"
	else
		new="$current,$OPT"
	fi
	sudo sed -i "s|^XKBOPTIONS=.*|XKBOPTIONS=\"$new\"|" "$FILE"
	echo "Alt/Win swap: ENABLED"
fi

sudo setupcon 2>/dev/null || true
