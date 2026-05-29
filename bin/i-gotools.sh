#!/bin/bash
set -euo pipefail

if ! command -v go &>/dev/null; then
	echo "go is not installed" >&2
	exit 1
fi

# ── Language servers ─────────────────────────────────────────────────
go install golang.org/x/tools/gopls@latest
go install github.com/bufbuild/buf-language-server/cmd/bufls@latest
go install github.com/leona/helix-assist/cmd/helix-assist@latest

# ── Debugger ─────────────────────────────────────────────────────────
go install github.com/go-delve/delve/cmd/dlv@latest

# ── Formatters ───────────────────────────────────────────────────────
go install mvdan.cc/gofumpt@latest
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/segmentio/golines@latest

# ── Linters ──────────────────────────────────────────────────────────
go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest
go install honnef.co/go/tools/cmd/staticcheck@latest

# ── Protobuf & gRPC ──────────────────────────────────────────────────
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@latest
go install github.com/bufbuild/buf/cmd/buf@latest
go install connectrpc.com/connect/cmd/protoc-gen-connect-go@latest
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
go install github.com/bojand/ghz/cmd/ghz@latest

# ── Database ─────────────────────────────────────────────────────────
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest

# ── Security ─────────────────────────────────────────────────────────
go install github.com/securego/gosec/v2/cmd/gosec@latest

# ── Dev tools ────────────────────────────────────────────────────────
go install github.com/air-verse/air@latest
go install github.com/goreleaser/goreleaser/v2@latest
go install github.com/boyter/scc/v3@latest

# ── Misc ─────────────────────────────────────────────────
go install github.com/peterldowns/nix-search-cli/cmd/nix-search@latest

# ── Screen recording ─────────────────────────────────────────────────
go install github.com/charmbracelet/vhs@latest

# ── Obfuscation ──────────────────────────────────────────────────────
go install mvdan.cc/garble@latest

# ── Telemetry ────────────────────────────────────────────────────────
go install golang.org/x/telemetry/cmd/gotelemetry@latest
gotelemetry off
