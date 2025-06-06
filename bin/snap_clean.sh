#!/bin/bash
# Removes old revisions of snaps
# CLOSE ALL SNAPS BEFORE RUNNING THIS

set -eu
sudo snap list --all | awk '/disabled/{print $1, $3}' |
	while read -r snapname revision; do
		sudo snap remove "$snapname" --revision="$revision"
	done
