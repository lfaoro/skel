# language server
go install golang.org/x/tools/gopls@latest
go install github.com/bufbuild/buf-language-server/cmd/bufls@latest

# debugger
go install github.com/go-delve/delve/cmd/dlv@latest

# formatters
go install github.com/nametake/golangci-lint-langserver@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install github.com/fatih/gomodifytags@latest
go install github.com/segmentio/golines@latest
go install mvdan.cc/gofumpt@latest
go install golang.org/x/tools/cmd/goimports@latest

# live reload
go install github.com/air-verse/air@latest

# obfuscation
go install mvdan.cc/garble@latest

# grpc
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/bufbuild/buf/cmd/buf@latest
go install connectrpc.com/connect/cmd/protoc-gen-connect-go@latest
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
go install github.com/bojand/ghz/cmd/ghz@latest

# telemetry
go install golang.org/x/telemetry/cmd/gotelemetry@latest
gotelemetry off

# database
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest

# screen recording
go install github.com/charmbracelet/vhs@latest
