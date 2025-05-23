#!/usr/bin/env bash
set -ex

# git clone https://github.com/lfaoro/skel --recurse-submodules
# git clone git@github.com:lfaoro/skel.git --recurse-submodules

git submodule update --init --recursive || :

sudo apt update &&
	sudo apt install -y curl git zsh make gcc

# if we're running a gui
if [ "$1" = "true" ]; then
	# enforce browser policy
	sudo mkdir -p /etc/brave/policies/managed
	sudo cp ./etc/chromium-policy.json /etc/brave/policies/managed/policy.json
	# remove keyboard delay
	gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 0
	gsettings set org.gnome.desktop.peripherals.keyboard delay 0
fi

sudo chown -R "$USER": .
# install alacritty terminfo
curl -sSL https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info | tic -x -
sudo localectl set-locale LANG=en_US.UTF-8

# create config.nix
if [[ ! -e "./config.nix" ]]; then
	cat <<EOF >./config.nix
{
    username = "$USER";
    homedir = "$HOME";
    useDevTools = false;
    useDconf = false;
    useGUI = $1;
    swapAltWin = false;
}
EOF
fi

if [[ ! -d '/nix' ]]; then
	sudo install -d -m755 -o $(id -u) -g $(id -g) /nix
	sh <(curl -L https://nixos.org/nix/install) --no-daemon
	source /home/user/.nix-profile/etc/profile.d/nix.sh
fi

# add unstable channel
nix-channel --add https://channels.nixos.org/nixpkgs-unstable nixpkgs

# install home-manager
nix-channel --add \
	https://github.com/nix-community/home-manager/archive/master.tar.gz \
	home-manager || :
mkdir -p ~/.config/home-manager
ln -sf ~/skel/home.nix ~/.config/home-manager/home.nix
mv -f ~/.bashrc ~/.bashrc.bak || :
nix-channel --update
nix-shell '<home-manager>' -A install

if [ "$1" = "true" ]; then
	# install nixGL to enable hardware acceleration for gui apps
	nix-channel --add https://github.com/nix-community/nixGL/archive/main.tar.gz nixgl
	nix-channel --update
	nix-env -iA nixgl.auto.nixGLDefault
fi

chsh -s /bin/zsh
