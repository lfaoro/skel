#!/usr/bin/env bash
# shellcheck shell=bash
#
# note — quick personal note manager
#
# Usage:
#   note              Edit today's note (YY-MM-DD.md)
#   note <name>       Edit <name>.md (extension optional)
#   note todo         Edit the TODO file
#   note all          View all notes through $PAGER
#   note ls           List all notes
#   note path         Print the notes directory path
#   note del [name]   Delete a note (today's if omitted; prompts)
#
# Environment variables:
#   NOTE_PATH   Notes directory (default: $HOME/sync/notes)
#   EDITOR      Editor command (default: hx)
#   PAGER       Pager for 'all' (default: less)

set -euo pipefail

NOTE_PATH="${NOTE_PATH:-$HOME/sync/notes}"
EDITOR="${EDITOR:-hx}"
PAGER="${PAGER:-less}"

mkdir -p "$NOTE_PATH"

usage() {
  cat >&2 <<'EOF'
note — quick personal note manager

Commands:
  note              Edit today's note
  note <name>       Edit <name>.md
  note todo         Edit TODO file
  note all          View all notes in pager
  note ls           List notes
  note path         Print notes directory
  note del [name]   Delete note (today if no name)

Examples:
  note              # edit 25-06-01.md
  note ideas        # edit ideas.md
  note del 25-05-10 # delete 25-05-10.md (with prompt)
EOF
  exit 1
}

cmd="${1:-}"

case "$cmd" in
  -h|--help|help)
    usage
    ;;

  "")
    # today's note
    "$EDITOR" "$NOTE_PATH/$(date +'%y-%m-%d').md"
    ;;

  todo)
    "$EDITOR" "$NOTE_PATH/TODO"
    ;;

  all)
    # Collect .md files safely (handle no matches)
    shopt -s nullglob
    files=("$NOTE_PATH"/*.md)
    shopt -u nullglob
    if [[ ${#files[@]} -eq 0 ]]; then
      echo "No notes found in $NOTE_PATH" >&2
      exit 0
    fi
    # shellcheck disable=SC2086
    ${PAGER} "${files[@]}"
    ;;

  ls|list)
    # Show everything in the notes dir, one per line
    # shellcheck disable=SC2012
    ls -1 "$NOTE_PATH" 2>/dev/null | cat
    ;;

  path)
    printf '%s\n' "$NOTE_PATH"
    ;;

  del|delete|rm)
    shift || true
    if [[ $# -ge 1 ]]; then
      name="$1"
      # allow user to pass "foo" or "foo.md"
      name="${name%.md}"
      target="$NOTE_PATH/$name.md"
    else
      target="$NOTE_PATH/$(date +'%y-%m-%d').md"
    fi
    if [[ ! -e "$target" ]]; then
      echo "note: no such note: $target" >&2
      exit 1
    fi
    rm -i "$target"
    ;;

  *)
    # arbitrary note name; strip trailing .md for convenience
    name="${cmd%.md}"
    "$EDITOR" "$NOTE_PATH/$name.md"
    ;;
esac

