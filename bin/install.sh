#!/usr/bin/env bash
set -ex

# git clone https://github.com/lfaoro/skel --recurse-submodules
# git clone git@github.com:lfaoro/skel.git --recurse-submodules

git submodule update --init --recursive ||:

sudo apt update && \
sudo apt install -y curl git zsh make gcc 

# if we're running a gui
if [ "$1" = "true" ]; then
  sudo apt install gnome-sushi dkms
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

# create config.nix
if [[ ! -e "./config.nix" ]]; then
  echo "
  {
    username = \"$USER\";
    homedir = \"$HOME\";
        useDevTools = false;
        useDconf = false;
        useGUI = $1;
        swapAltWin = false;
  }"> ./config.nix
fi

if [[ ! -d '/nix' ]]; then
  curl -L https://nixos.org/nix/install --no-daemon
  source /home/user/.nix-profile/etc/profile.d/nix.sh
fi

  # add the experimental config to nix.conf so we can use flakes and search
  # sudo mkdir -p /etc/nix
  # echo "experimental-features = nix-command flakes" |sudo tee -a /etc/nix/nix.conf


# xchan='/nix/var/nix/profiles/default/bin/nix-channel'
# xenv='/nix/var/nix/profiles/default/bin/nix-env'
xchan='nix-channel'
xenv='nix-env'
# install home-manager
$xchan --add \
https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
# add unstable channel
$xchan --add https://channels.nixos.org/nixpkgs-unstable nixpkgs 

mkdir -p ~/.config/home-manager
ln -sf ~/skel/home.nix ~/.config/home-manager/home.nix
if $xchan --list |grep -q home-manager; then 
  mv -f ~/.bashrc ~/.bashrc.bak ||:
  $xchan --update
  $xenv -iA nixpkgs.home-manager
fi 

if [ "$1" = "true" ]; then
# install nixGL to enable hardware acceleration for nix-GUI tmpDirpps
$xchan --add https://github.com/nix-community/nixGL/archive/main.tar.gz nixgl
  $xenv -iA nixgl.auto.nixGLDefault
fi

chsh -s /bin/zsh

# update-alternatives --config editor
# sudo ln -fs "$(which hx)" /etc/alternatives/editor
