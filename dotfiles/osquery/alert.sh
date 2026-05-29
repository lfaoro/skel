#!/usr/bin/env bash
LOG="$HOME/.local/share/osquery/log/osqueryd.results.log"
MARKER="$HOME/.local/share/osquery/log/.alert_marker"

if [ ! -f "$LOG" ]; then exit 0; fi

if [ ! -f "$MARKER" ]; then
    wc -l < "$LOG" > "$MARKER"
    exit 0
fi

LAST_LINES=$(cat "$MARKER")
CURRENT_LINES=$(wc -l < "$LOG")

if [ "$CURRENT_LINES" -gt "$LAST_LINES" ]; then
    NEW_CONTENT=$(tail -n +$((LAST_LINES + 1)) "$LOG" | head -20)
    notify-send -u critical "osquery Alert" "$NEW_CONTENT" -t 10000
fi

echo "$CURRENT_LINES" > "$MARKER"
