#!/usr/bin/env bash
# shellcheck shell=bash
#
# Encrypt/decrypt a tarball using openssl with a generated password.
#
# Usage (direct):  ./encrypto.sh encrypt <dir> [password]
#                  ./encrypto.sh decrypt <file.enc> <password>
# Usage (sourced): encrypt <dir>
#                  decrypt <file.enc> <password>
#
# encrypt: tarball + 32-char password -> .tgz.enc, prints decrypt commands
# decrypt: decrypt .tgz.enc -> tgz -> extract -> cleanup

encrypt() {
  local input="$1"
  local tarball="${input##*/}.tgz"
  local encrypted_file="${tarball}.enc"
  local password

  err() { printf 'Error: %s\n' "$1" >&2; return 1; }

  [[ -n "$input" ]] || { err "Input directory or file required."; return 1; }
  [[ -e "$input" ]] || { err "Input '$input' does not exist."; return 1; }

  printf 'Creating tarball: %s\n' "$tarball"
  tar -czf "$tarball" "$input" || { rm -f "$tarball"; err "Failed to create tarball."; return 1; }

  password=$(openssl rand -base64 24)
  if [[ ${#password} -ne 32 ]]; then
    rm -f "$tarball"
    err "Failed to generate a 32-character password."
    return 1
  fi

  printf 'Encrypting tarball to %s\n' "$encrypted_file"
  if ! openssl enc -aes-256-cbc -pbkdf2 -salt \
    -in "$tarball" -out "$encrypted_file" -pass pass:"$password"; then
    rm -f "$tarball"
    err "Encryption failed."
    return 1
  fi

  rm -f "$tarball"
  printf 'Encrypted file: %s\n' "$encrypted_file"
  printf '\nCopy and paste one of the following to decrypt:\n'
  printf '  decrypt %s "%s"\n' "$encrypted_file" "$password"
  printf '  openssl enc -aes-256-cbc -pbkdf2 -d -in %s -out %s -pass pass:"%s"\n' \
    "$encrypted_file" "$tarball" "$password"
  printf '  tar -xzf %s\n' "$tarball"
  printf '  rm -f %s\n' "$tarball"
}

decrypt() {
  local encrypted_file="$1"
  local password="$2"
  local tarball="${encrypted_file%.enc}"

  err() { printf 'Error: %s\n' "$1" >&2; return 1; }

  [[ -n "$encrypted_file" && -n "$password" ]] || { err "Encrypted file and password required."; return 1; }
  [[ "$encrypted_file" == *.enc ]] || { err "Input file must have .enc extension."; return 1; }
  [[ -e "$encrypted_file" ]] || { err "Encrypted file '$encrypted_file' does not exist."; return 1; }

  printf 'Decrypting %s to %s\n' "$encrypted_file" "$tarball"
  if ! openssl enc -aes-256-cbc -pbkdf2 -d \
    -in "$encrypted_file" -out "$tarball" -pass pass:"$password"; then
    err "Decryption failed. Check the password."
    return 1
  fi

  printf 'Extracting %s\n' "$tarball"
  if ! tar -xzf "$tarball"; then
    rm -f "$tarball"
    err "Failed to extract tarball."
    return 1
  fi

  rm -f "$tarball"
  printf 'Decryption and extraction complete.\n'
}

# Direct execution only — nothing below leaks into shell when sourced
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]]; then
  set -euo pipefail

  if ! command -v openssl &>/dev/null || ! command -v tar &>/dev/null; then
    printf 'Error: openssl and tar are required.\n' >&2
    exit 1
  fi

  usage() {
    cat >&2 <<-EOF
	Usage (direct):  $0 encrypt <directory_or_file> [password]
	                 $0 decrypt <file.enc> <password>
	Usage (sourced): encrypt <directory_or_file>
	                 decrypt <file.enc> <password>
	  encrypt: Create and encrypt a tarball with a generated 32-character password.
	  decrypt: Decrypt and extract a tarball (password required).
	EOF
    exit 1
  }

  [[ $# -ge 2 ]] && [[ $# -le 3 ]] || usage

  case "${1-}" in
    encrypt) encrypt "${2-}";;
    decrypt) decrypt "${2-}" "${3-}";;
    *) usage;;
  esac
fi
