#!/usr/bin/env bash
# shellcheck shell=bash
#
# Create a new tmux session with an auto-generated name:
#   main, 2nd, 3rd, 4th, ... (first session is "main", then ordinals)
#
# Usage: new-session.sh [name]
#   With a name argument, creates that session instead of auto-naming.
#
# Inside tmux: creates the session detached and switches the client to it.
# Outside tmux: attaches to the new session.

set -euo pipefail

ordinal() {
  local n=$1 suffix
  case $((n % 100)) in
    11 | 12 | 13) suffix=th ;;
    *)
      case $((n % 10)) in
        1) suffix=st ;;
        2) suffix=nd ;;
        3) suffix=rd ;;
        *) suffix=th ;;
      esac
      ;;
  esac
  printf '%d%s\n' "$n" "$suffix"
}

next_name() {
  if ! tmux has-session -t main 2>/dev/null; then
    printf 'main\n'
    return
  fi
  local n=2
  while tmux has-session -t "$(ordinal "$n")" 2>/dev/null; do
    n=$((n + 1))
  done
  ordinal "$n"
}

name=${1:-$(next_name)}

if [[ -n "${TMUX:-}" ]]; then
  tmux new-session -d -s "$name"
  tmux switch-client -t "$name"
else
  tmux new-session -s "$name"
fi
