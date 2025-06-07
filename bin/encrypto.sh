#!/bin/bash

# Script to encrypt/decrypt a tarball using openssl with a password
# Usage (when run directly): ./encrypt_decrypt_tarball.sh {encrypt|decrypt} <directory_or_file> [password]
# Usage (when sourced): source ./encrypt_decrypt_tarball.sh; encrypt <directory_or_file> or decrypt <file> <password>
# - encrypt: Creates a tarball with fast compression (.tgz), generates a 32-character password, encrypts it, and outputs decryption commands
# - decrypt: Decrypts and extracts a tarball using provided password
# Outputs both script-based and standalone decryption commands during encryption

# Check if openssl and tar are installed
if ! command -v openssl &>/dev/null || ! command -v tar &>/dev/null; then
    echo "Error: 'openssl' and 'tar' are required."
    echo "Install them using your package manager (e.g., 'sudo apt install openssl tar' on Debian/Ubuntu)."
    return 1 2>/dev/null || exit 1
fi

# Function to display usage
usage() {
    echo "Usage (direct): $0 {encrypt|decrypt} <directory_or_file> [password]"
    echo "Usage (sourced): encrypt <directory_or_file> or decrypt <file> <password>"
    echo "  encrypt: Create and encrypt a tarball from a directory or file with a generated 32-character password."
    echo "  decrypt: Decrypt and extract a tarball (password required for decrypt)."
    return 1 2>/dev/null || exit 1
}

# Encryption function
encrypt() {
    local input=$1
    local tarball="${input##*/}.tgz"
    local encrypted_file="${tarball}.enc"

    # Validate input
    if [ -z "$input" ]; then
        echo "Error: Input directory or file required."
        usage
    fi
    if [ ! -e "$input" ]; then
        echo "Error: Input '$input' does not exist."
        return 1 2>/dev/null || exit 1
    fi

    # Create tarball with fast compression
    echo "Creating tarball: $tarball"
    if ! tar -czf "$tarball" "$input"; then
        echo "Error: Failed to create tarball."
        return 1 2>/dev/null || exit 1
    fi

    # Generate a 32-character password
    password=$(openssl rand -base64 24)
    if [ ${#password} -ne 32 ]; then
        echo "Error: Failed to generate a 32-character password."
        rm -f "$tarball"
        return 1 2>/dev/null || exit 1
    fi

    # Encrypt tarball with pbkdf2
    echo "Encrypting tarball to $encrypted_file"
    if ! openssl enc -aes-256-cbc -pbkdf2 -salt -in "$tarball" -out "$encrypted_file" -pass pass:"$password"; then
        echo "Error: Encryption failed."
        rm -f "$tarball"
        return 1 2>/dev/null || exit 1
    fi

    # Remove unencrypted tarball
    rm -f "$tarball"
    echo "Encrypted file: $encrypted_file"

    # Output decryption commands
    echo -e "\nCopy and paste one of the following to decrypt:"
    echo "   decrypt $encrypted_file \"$password\""
    echo "   openssl enc -aes-256-cbc -pbkdf2 -d -in $encrypted_file -out $tarball -pass pass:\"$password\""
    echo "   tar -xzf $tarball"
    echo "   rm -f $tarball"
}

# Decryption function
decrypt() {
    local encrypted_file=$1
    local password=$2
    local tarball="${encrypted_file%.enc}"

    # Validate inputs
    if [ -z "$encrypted_file" ] || [ -z "$password" ]; then
        echo "Error: Encrypted file and password required."
        usage
    fi
    if [[ ! "$encrypted_file" =~ \.enc$ ]]; then
        echo "Error: Input file must have .enc extension."
        return 1 2>/dev/null || exit 1
    fi
    if [ ! -e "$encrypted_file" ]; then
        echo "Error: Encrypted file '$encrypted_file' does not exist."
        return 1 2>/dev/null || exit 1
    fi

    # Decrypt file
    echo "Decrypting $encrypted_file to $tarball"
    if ! openssl enc -aes-256-cbc -pbkdf2 -d -in "$encrypted_file" -out "$tarball" -pass pass:"$password"; then
        echo "Error: Decryption failed. Check the password."
        return 1 2>/dev/null || exit 1
    fi

    # Extract tarball
    echo "Extracting $tarball"
    if ! tar -xzf "$tarball"; then
        echo "Error: Failed to extract tarball."
        rm -f "$tarball"
        return 1 2>/dev/null || exit 1
    fi

    # Remove temporary tarball
    rm -f "$tarball"
    echo "Decryption and extraction complete."
}

# Check if script is sourced or run directly
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Script is sourced; define functions and do nothing else
    return 0
else
    # Script is run directly; process command-line arguments
    if [ $# -lt 2 ] || [ $# -gt 3 ]; then
        usage
    fi

    ACTION=$1
    INPUT=$2
    PASSWORD=$3

    case "$ACTION" in
        encrypt)
            encrypt "$INPUT"
            ;;
        decrypt)
            decrypt "$INPUT" "$PASSWORD"
            ;;
        *)
            usage
            ;;
    esac
fi
