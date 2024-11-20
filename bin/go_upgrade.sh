#!/usr/bin/env bash
set -e

tmp=$(mktemp -d)
pushd "$tmp" || exit 1

function cleanup {
    popd || exit 1
    rm -rf "$tmp"
}
trap cleanup EXIT

version=$(go version |cut -d' ' -f3)
release=$(wget -qO- "https://golang.org/VERSION?m=text"| grep go)
release_file="${release}.linux-amd64.tar.gz"

if [[ $version == "$release" ]]; then
    echo "local Go version ${release} is the latest."
    exit 0
else
    echo "local Go version ${version}, new release ${release} is available."
fi


echo "Downloading https://go.dev/dl/$release_file ..." 
curl -OL https://go.dev/dl/"$release_file"

goroot=$(go env |grep GOROOT |cut -d'=' -f2 |tr -d '"'|tr -d"'")
echo "GOROOT: $goroot"
sudo tar -C "${goroot//go}" -xzf "$release_file"

version=$(go version |cut -d' ' -f3)
echo "local Go version is $version (latest)"
