#!/usr/bin/env bash
set -ex
tmpDir="tmp"
mkdir -p $tmpDir

# git clone https://github.com/lfaoro/skel.git
# git clone git@github.com:lfaoro/skel.git
# git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

sudo apt update && \
sudo apt install -y curl git zsh make gcc gnome-sushi linux-headers-generic dkms
snap install mpv ffmpeg vlc
sudo chown -R "$USER": .

# store secret env keys here
var SECRETS_FILE="$HOME/.secrets"
if [[ ! -e "$SECRETS_FILE" ]]; then
  echo "# export SECRET_VAR=SECRET_KEY" >"$SECRETS_FILE"
fi

# install alacritty terminfo
curl -sSL https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info | tic -x -

# set locale
localectl set-locale LANG=en_US.UTF-8

# enforce browser policy
sudo mkdir -p /etc/brave/policies/managed
sudo cp ./chromium-policy.json /etc/brave/policies/managed/policy.json

if [[ ! -e $(which nix) ]]; then
  # install nix package manager
  sh <(curl -L https://nixos.org/nix/install) --daemon
  # add the experimental config to nix.conf so we can use flakes and search
  echo "experimental-features = nix-command flakes" |sudo tee -a /etc/nix/nix.conf
fi

# install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
# install nixGL to enable hardware acceleration for nix-GUI tmpDirpps
nix-channel --add https://github.com/nix-community/nixGL/archive/main.tar.gz nixgl
# unstable
nix-channel --add https://channels.nixos.org/nixpkgs-unstable nixpkgs 

if [[ $(nix-channel --list|grep home) -eq 1 ]]; then 
  nix-channel --update
  nix-shell '<home-manager>' -A install
  nix-env -iA nixgl.auto.nixGLDefault
fi 

mkdir -p ~/.config/home-manager
ln -sf ~/skel/home.nix ~/.config/home-manager/home.nix

# backup user.nix if exists
if [[ -e "$tmpDir/user.nix" ]]; then
  mv $tmpDir/user.nix $tmpDir/user.nix.bak
fi
# create user.nix based on current user
echo "
{
  home.username = \"$USER\";
  home.homeDirectory = \"$HOME\";
}"> $tmpDir/user.nix

# create config.nix
echo "
{
	useDevTools = false;
	useDconf = false;
	useGUI = false;
	swapAltWin = false;
}"> $tmpDir/config.nix

home-manager switch -b bak
systemctl --user start cronjobs.service

# update-alternatives --config editor
sudo ln -fs "$(which hx)" /etc/alternatives/editor

printf "restart your terminal"
