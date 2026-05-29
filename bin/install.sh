#!/usr/bin/env bash
# shellcheck shell=bash
set -eo pipefail

yes_no() { [[ "${1,,}" == y || "${1,,}" == yes ]]; }

# git clone https://github.com/lfaoro/skel --recurse-submodules
# git clone git@github.com:lfaoro/skel.git --recurse-submodules

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SCRIPT_DIR"

git submodule update --init --recursive 2>/dev/null || true
git config core.hooksPath hooks

sudo apt update
sudo apt install -y curl git zsh make gcc
sudo chsh -s "$(command -v zsh)" "$USER"

sudo chown -R "$USER:$USER" .

curl -sSL https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info | tic -x - 2>/dev/null || true
command -v localectl &>/dev/null && sudo localectl set-locale LANG=en_US.UTF-8 2>/dev/null || true

mkdir -p ~/.sec && touch ~/.sec/keys

  git_name=$(git config --global user.name 2>/dev/null || echo "$USER")
  git_email=$(git config --global user.email 2>/dev/null || echo "${USER}@$(hostname 2>/dev/null || echo localhost)")

if [[ ! -e "./config.nix" ]]; then
  if [[ -t 0 ]]; then
    echo "==> configure your environment"
    read -r -p "Install developer tools (Go, Rust, Zig, Node, LSPs)? [y/N]: " cfg_dev
    read -r -p "Apply GNOME dconf settings? [y/N]: " cfg_dconf
    read -r -p "Install GUI applications? [y/N]: " cfg_gui
    read -r -p "Install network scanning tools (nmap, tshark, etc.)? [y/N]: " cfg_net
    read -r -p "Install miscellaneous CLI tools (jump, lynx, etc.)? [y/N]: " cfg_misc
    read -r -p "Remap Caps Lock to Ctrl? [y/N]: " cfg_caps
  else
    cfg_dev="n"; cfg_dconf="n"; cfg_gui="n"; cfg_net="n"; cfg_misc="n"; cfg_caps="n"
  fi

  cat > ./config.nix <<EOF
{
    username = "$USER";
    homedir = "$HOME";
    useDevTools = $(yes_no "$cfg_dev" && echo "true" || echo "false");
    useDconf = $(yes_no "$cfg_dconf" && echo "true" || echo "false");
    useGUI = $(yes_no "$cfg_gui" && echo "true" || echo "false");
    useNetworkTools = $(yes_no "$cfg_net" && echo "true" || echo "false");
    useMisc = $(yes_no "$cfg_misc" && echo "true" || echo "false");

    gitName = "$git_name";
    gitEmail = "$git_email";
    gitGpgKey = "";
    gitSignByDefault = false;
}
EOF

  if yes_no "$cfg_caps"; then
    ./bin/caps2ctrl.sh || :
  fi
fi

gui_enabled() { grep -q 'useGUI\s*=\s*true' config.nix 2>/dev/null; }

if gui_enabled; then
  sudo mkdir -p /etc/brave/policies/managed
  sudo cp ./etc/chromium-policy.json /etc/brave/policies/managed/policy.json
  if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 0
    gsettings set org.gnome.desktop.peripherals.keyboard delay 0
  fi
fi

if [[ ! -d '/nix' ]]; then
  sudo install -d -m755 -o "$(id -u)" -g "$(id -g)" /nix
  sh <(curl -L https://nixos.org/nix/install) --no-daemon
  # shellcheck disable=SC1091
  source "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

nix-channel --add https://channels.nixos.org/nixpkgs-unstable nixpkgs 2>/dev/null || true
nix-channel --add \
  https://github.com/nix-community/home-manager/archive/master.tar.gz \
  home-manager 2>/dev/null || true

if gui_enabled; then
  nix-channel --add https://github.com/nix-community/nixGL/archive/main.tar.gz nixgl 2>/dev/null || true
fi

mkdir -p ~/.config/home-manager
ln -sf "$SCRIPT_DIR/home.nix" ~/.config/home-manager/home.nix

if [[ -f ~/.bashrc ]]; then
  bak=~/.bashrc.bak
  [[ -f "$bak" ]] && bak=~/.bashrc."$(date +%s)".bak
  cp ~/.bashrc "$bak"
fi

nix-channel --update
nix-shell '<home-manager>' -A install

# install tmux plugins (belt-and-suspenders: also auto-installed by tmux at startup)
if command -v git &>/dev/null && [[ ! -d ~/.tmux/plugins/tpm || -z "$(ls -A ~/.tmux/plugins/tpm 2>/dev/null)" ]]; then
  rm -rf ~/.tmux/plugins/tpm
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  ~/.tmux/plugins/tpm/bin/install_plugins
fi

if gui_enabled; then
  nix-env -iA nixgl.auto.nixGLDefault 2>/dev/null || true
fi

if yes_no "$cfg_caps"; then
  ./bin/caps2ctrl.sh || :
fi
