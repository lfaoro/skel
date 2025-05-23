#!/usr/bin/env bash
NOTE_PATH="$HOME/sync/notes"
if [ "$1" = "all" ]; then
  "$PAGER $NOTE_PATH/*.md"
elif [ "$1" = "todo" ]; then
  hx "$NOTE_PATH/TODO"
elif [ "$1" = "del" ]; then
  rm -i "$NOTE_PATH/$(date +'%y-%m-%d').md"
elif [ "$1" = "" ]; then
  $EDITOR "$NOTE_PATH/$(date +'%y-%m-%d').md"
else 
  $EDITOR "$NOTE_PATH/$1.md"
fi
