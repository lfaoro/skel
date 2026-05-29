# Widget to insert the first word of the previous command
insert-first-word() {
  LBUFFER+="${${(z)history[$((HISTCMD-1))]}[1]}"
}
zle -N insert-first-word
bindkey '^[,' insert-first-word
