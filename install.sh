#!/usr/bin/env bash
set -ex

# git clone https://github.com/lfaoro/skel --recurse-submodules
# git clone git@github.com:lfaoro/skel.git --recurse-submodules

git submodule update --init --recursive

sudo apt update && \
sudo apt install -y curl git zsh make gcc linux-headers-generic dkms
if pgrep -f "gnome|mate|cinnamon|unity|kde|lxde|xfce|Xorg|wayland|gdm|lightdm|sddm|xdm" > /dev/null; then
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

# backup config.nix if exists
if [[ -e "./config.nix" ]]; then
  mv ./config.nix ./config.nix.bak
fi

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

# install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
# install nixGL to enable hardware acceleration for nix-GUI tmpDirpps
nix-channel --add https://github.com/nix-community/nixGL/archive/main.tar.gz nixgl
# unstable
nix-channel --add https://channels.nixos.org/nixpkgs-unstable nixpkgs 

mkdir -p ~/.config/home-manager
ln -sf ~/skel/home.nix ~/.config/home-manager/home.nix

if [[ $(nix-channel --list|grep home) -eq 1 ]]; then 
  nix-channel --update

  rm -f ~/.bashrc
  nix-shell '<home-manager>' -A install

  nix-env -iA nixgl.auto.nixGLDefault
fi 

# update-alternatives --config editor
# sudo ln -fs "$(which hx)" /etc/alternatives/editor
