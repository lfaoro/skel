.PHONY: help fmt lint check switch all install news clean

# Prefer locally installed tools, otherwise fall back to nix run (works in minimal envs)
NIXFMT     := $(shell command -v nixfmt     2>/dev/null || echo 'nix run nixpkgs#nixfmt --')
SHELLCHECK := $(shell command -v shellcheck 2>/dev/null || echo 'nix run nixpkgs#shellcheck --')
HM         := $(shell command -v home-manager 2>/dev/null || echo 'nix run home-manager --')

help:
	@echo "skel - personal dotfiles (home-manager)"
	@echo ""
	@echo "Targets:"
	@echo "  make fmt      - format Nix files (nixfmt)"
	@echo "  make lint     - lint shell scripts (shellcheck)"
	@echo "  make check    - dry-run home-manager (safe)"
	@echo "  make switch   - apply configuration"
	@echo "  make all      - fmt + lint + check   (run before committing)"
	@echo "  make install  - run the bootstrap installer"
	@echo "  make news     - show home-manager news"
	@echo ""
	@echo "Before committing: make all"

fmt:
	$(NIXFMT) home.nix dconf.nix

lint:
	$(SHELLCHECK) bin/*.sh shell/.aliasrc

check:
	$(HM) switch -n

switch:
	$(HM) switch

all: fmt lint check

install:
	./bin/install.sh

news:
	$(HM) news

clean:
	@echo "Run 'clean' via the shell function (in .aliasrc) for full system cleanup"
