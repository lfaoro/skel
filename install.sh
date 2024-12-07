#!/usr/bin/env bash
set -ex

# git clone https://github.com/lfaoro/skel --recurse-submodules
# git clone git@github.com:lfaoro/skel.git --recurse-submodules

git submodule update --init --recursive

sudo apt update && \
sudo apt install -y curl git zsh make gcc dkms

# if we're running a guy
if [ "$1" = "true" ]; then
  sudo apt install gnome-sushi
  snap install mpv ffmpeg vlc
  # enforce browser policy
  sudo mkdir -p /etc/brave/policies/managed
  sudo cp ./etc/chromium-policy.json /etc/brave/policies/managed/policy.json
fi

sudo chown -R "$USER": .
mkdir -p "$HOME/.sec"
touch "$HOME/.sec/keys"

# install alacritty terminfo
curl -sSL https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info | tic -x -

# set locale
sudo localectl set-locale LANG=en_US.UTF-8

if [[ ! -e $(which nix) ]]; then
  # install nix package manager
  sh <(curl -L https://nixos.org/nix/install) --daemon
  # add the experimental config to nix.conf so we can use flakes and search
  echo "experimental-features = nix-command flakes" |sudo tee -a /etc/nix/nix.conf
fi

# start a new shell
exec "$SHELL" || exec /bin/sh

# backup config.nix if exists
if [[ ! -e "./config.nix" ]]; then
  # create config.nix
  echo "
  {
    username = \"$USER\";
    homedir = \"$HOME\";
  	useDevTools = false;
  	useDconf = false;
  	useGUI = false;
  	swapAltWin = false;
  }"> ./config.nix
fi

# install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
# unstable
nix-channel --add https://channels.nixos.org/nixpkgs-unstable nixpkgs 
if [ "$1" = "true" ]; then
  # install nixGL to enable hardware acceleration for nix-GUI tmpDirpps
  nix-channel --add https://github.com/nix-community/nixGL/archive/main.tar.gz nixgl
fi

mkdir -p ~/.config/home-manager
ln -sf ~/skel/home.nix ~/.config/home-manager/home.nix

if nix-channel --list |grep -q home-manager; then 
  nix-channel --update
  mv -f ~/.bashrc ~/.bashrc.bak
  nix-shell '<home-manager>' -A install
  if [ "$1" = "true" ]; then
    nix-env -iA nixgl.auto.nixGLDefault
  fi
fi 

chsh -s /bin/zsh

# update-alternatives --config editor
# sudo ln -fs "$(which hx)" /etc/alternatives/editor
