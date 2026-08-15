.PHONY: help fmt lint check switch all install news clean fresh

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
	@echo "  make fresh    - rewrite repo as single commit (DANGEROUS)"
	@echo ""
	@echo "Before committing: make all"

fmt:
	$(NIXFMT) $$(find . -name '*.nix' -not -path './scratch/*' -not -path './tmp/*')

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

# Rewrites the entire repo history into a single root commit.
# Use this when you want a clean publish with no previous history.
fresh:
	@echo "⚠️  WARNING: This rewrites git history into ONE commit."
	@echo "   It will destroy all previous commits when force-pushed."
	@echo ""
	@echo "Recommended backup first:"
	@echo "    git clone --mirror . ../skel-backup-$(shell date +%Y%m%d).git"
	@echo ""
	@read -p "Type 'yes' to continue: " ans; [ "$$ans" = "yes" ] || (echo "Aborted." && exit 1)
	git checkout --orphan fresh
	git rm -rf . > /dev/null 2>&1 || true
	git checkout main -- .
	git add -A
	git commit -m "Initial commit"
	git branch -M main
	@echo ""
	@echo "✅ Single-commit history ready."
	@echo "To publish, run:"
	@echo "    git push --force origin main"
	@echo ""
	@echo "After pushing, run on other clones:"
	@echo "    git fetch --all && git reset --hard origin/main"
