# Function to convert dots to cd commands
function dot_up () {
    local depth=$(( ${#BUFFER} - 1 ))
    if [[ $BUFFER =~ '^\.+$'\ && $depth -ge 2 ]]; then
        local dest_path=""
        for (( i=0; i<$depth-1; i++ )); do
            dest_path+="../"
        done
        echo -n "cd $dest_path"
        zle reset-prompt
        return 0
    fi
    return 1
}

# Add the function to the zle widgets
zle -N dot_up

# Bind the function to the accept-line widget
bindkey '^M' accept-line

# Precmd hook to execute dot_up before displaying prompt
precmd() {
    if [[ $BUFFER =~ '^\.+$'\ && ${#BUFFER} -ge 2 ]]; then
        dot_up
    fi
}

function f() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
