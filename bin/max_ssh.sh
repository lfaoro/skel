#!/bin/bash

# Maximize SSH client connection compatibility.

SSH_CONFIG="$HOME/.ssh/config"
cp "$SSH_CONFIG" "${SSH_CONFIG}.bak"
mkdir -p "$HOME/.ssh"
touch "$SSH_CONFIG"

get_supported() {
    ssh -Q "$1" | tr '\n' ',' | sed 's/,$//'
}
# Get supported ciphers, macs, kex, and key types
ciphers=$(get_supported cipher)
macs=$(get_supported mac)
kex=$(get_supported kex)
host_key_algorithms=$(get_supported key)
pubkey_accepted_algorithms=$(get_supported key)

temp_config=$(mktemp)

cat << EOF > "$temp_config"
# Default configuration for maximum SSH compatibility
Host *
    # Enabling all supported ciphers
    Ciphers +$ciphers

    # Enabling all supported key exchange algorithms
    KexAlgorithms +$kex

    # Enabling all supported MACs
    MACs +$macs

    # Enable legacy host key algorithms
    HostKeyAlgorithms +$host_key_algorithms

    # Enable all supported key types for authentication
    PubkeyAcceptedAlgorithms +$pubkey_accepted_algorithms

    # Compression algorithms
    Compression yes
    CompressionLevel 6
EOF

cat "$temp_config" >> "$SSH_CONFIG"
rm "$temp_config"

echo "User SSH configuration has been updated with maximum compatibility settings."
echo "A backup of the original configuration has been saved as ${SSH_CONFIG}.bak"
echo "NB: This configuration increases compatibility at the cost of security. Use with caution."
