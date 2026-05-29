#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

sudo apt update && sudo apt install extrepo -y
sudo extrepo enable librewolf
sudo apt update && sudo apt install librewolf -y
