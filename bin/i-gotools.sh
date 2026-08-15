#!/bin/bash
set -euo pipefail

if ! command -v go &>/dev/null; then
	echo "go is not installed" >&2
	exit 1
fi

# ──────────────────────────────────────────────────────────────────────
# Go-version-coupled tools that neither go-overlay nor nixpkgs ship
# prebuilt for the installed toolchain. Built with `go install` so they
# are compiled against the active Go version.
#
# Everything else lives in home.nix:
#   - go-bin.latestStable.withDefaultTools → gopls, dlv, golangci-lint,
#     staticcheck, gofumpt, govulncheck (version-locked, Cachix-cached)
#   - modules/packages/dev.nix → standalone tools (buf, sqlc, grpcurl, …)
# ──────────────────────────────────────────────────────────────────────

# Formatters (parse Go source → must match the Go version)
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/segmentio/golines@latest

# Security linter (go/ast + go/types based)
go install github.com/securego/gosec/v2/cmd/gosec@latest

# Build obfuscator (compiler wrapper → must match the exact Go minor)
go install mvdan.cc/garble@latest

# Telemetry is disabled via the builtin (no gotelemetry binary needed)
go telemetry off
