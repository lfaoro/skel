# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$DOT/bin" ] ; then
    PATH="$DOT/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

GO_BIN="/usr/local/go/bin"
if [ -d "$GO_BIN" ]; then
    PATH="$GO_BIN:$PATH"
fi

GO_APP_BIN="$HOME/go/bin"
if [ -d "$GO_APP_BIN" ]; then
    PATH="$GO_APP_BIN:$PATH"
fi

