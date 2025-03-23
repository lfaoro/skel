.PHONY: all gc clean-kernels

all: sub
	nixfmt *.nix
	find . -type f -exec chmod 600 {} \;
	find . -type d -exec chmod 700 {} \;
	chmod 700 bin/*
	git add .

sub:
	git submodule update --init --recursive
	
gc:
	nix-channel --update
	nix-store --gc
	nix-collect-garbage -d
	nix store optimise

clean-kernels:
	dpkg --list |grep linux-image |grep -v "$(uname -r)" |cut -d' ' -f3 |xargs apt remove -y
