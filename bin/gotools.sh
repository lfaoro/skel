# language server
go install golang.org/x/tools/gopls@latest

# debugger
go install github.com/go-delve/delve/cmd/dlv@latest

# tools
go install golang.org/x/tools/cmd/gofmt@latest
go install github.com/nametake/golangci-lint-langserver@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install github.com/fatih/gomodifytags@latest
go install github.com/segmentio/golines@latest
go install mvdan.cc/gofumpt@latest
go install golang.org/x/tools/cmd/goimports@latest


# obfuscation
go install mvdan.cc/garble@latest

# grpc
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
