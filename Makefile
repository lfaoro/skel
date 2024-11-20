.PHONY: all gc install clean clean-kernel

all:
	@echo "works"

gc:
	nix-store --gc
	nix-collect-garbage -d
	nix store optimise

install:
	chsh -s ${which zsh}

	nix-store --help &>/dev/null || sh <(curl -L https://nixos.org/nix/install) --daemon
	echo "experimental-features = nix-command flakes" |sudo tee -a /etc/nix/nix.conf
	ln -sf ~/skel/home.nix ~/.config/home-manager/home.nix
	# backup user.nix if exists
	if [[ -e user.nix ]]; then
	  mv user.nix user.nix.bak
	fi
	# create user.nix based on current user
	echo "
	{
	  home.username = $USER;
	  home.homeDirectory = $HOME;
	}"> user.nix
	home-manager switch -b bak
	systemctl --user start cronjobs.service

	sudo update-alternatives --config editor

clean:
	@/nix/var/nix/profiles/default/bin/nix-channel --update
	@/nix/var/nix/profiles/default/bin/nix-store --gc
	@/nix/var/nix/profiles/default/bin/nix-collect-garbage -d

clean-kernel:
	dpkg --list |grep linux-image |grep -v "$(uname -r)" |cut -d' ' -f3 |xargs apt remove -y
