#!/usr/bin/env bash
# Shared sensitive data detection — sourced by pre-commit and pre-push hooks.

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

LABELS=(
	'BEGIN[[:space:]]+RSA[[:space:]]+PRIVATE[[:space:]]+KEY'      'private key block'
	'BEGIN[[:space:]]+DSA[[:space:]]+PRIVATE[[:space:]]+KEY'      'private key block'
	'BEGIN[[:space:]]+EC[[:space:]]+PRIVATE[[:space:]]+KEY'       'private key block'
	'BEGIN[[:space:]]+OPENSSH[[:space:]]+PRIVATE[[:space:]]+KEY'  'private key block'
	'BEGIN[[:space:]]+PGP[[:space:]]+PRIVATE[[:space:]]+KEY'      'private key block'
	'<PrivateKey>'                                                 'KeeShare private key'
	'AKIA[0-9A-Z]{16}'                                            'AWS access key ID'
	'sk_live_[[:alnum:]]{24,}'                                    'Stripe live secret key'
	'ghp_[A-Za-z0-9_]{36}'                                        'GitHub personal access token'
	'gho_[A-Za-z0-9_]{36}'                                        'GitHub OAuth token'
	'ghs_[A-Za-z0-9_]{36}'                                        'GitHub server-to-server token'
	'glpat-[0-9a-zA-Z\-]{20,}'                                    'GitLab personal access token'
	'AIza[0-9A-Za-z\-_]{35}'                                      'Google API key'
	'sk-[a-zA-Z0-9]{48}'                                          'OpenAI API key'
	'xox[baprs]-[0-9a-zA-Z_-]{10,}'                               'Slack bot/user token'
	'password[[:space:]]*[:=][[:space:]]*["\x27][^"$[:space:]\x27][^"[:space:]\x27]*["\x27]' 'hardcoded password'
	'secret[[:space:]]*[:=][[:space:]]*["\x27][^"$[:space:]\x27][^"[:space:]\x27]*["\x27]'   'hardcoded secret'
	'token[[:space:]]*[:=][[:space:]]*["\x27][^"$[:space:]\x27][^"[:space:]\x27]*["\x27]'    'hardcoded token'
	'api_key[[:space:]]*[:=][[:space:]]*["\x27][^"$[:space:]\x27][^"[:space:]\x27]*["\x27]'  'hardcoded API key'
)

# scan_content <ref> <file>
scan_content() {
	local ref="$1" file="$2" found=0

	local grep_args=()
	local i
	for ((i = 0; i < ${#LABELS[@]}; i += 2)); do
		grep_args+=(-e "${LABELS[$i]}")
	done

	local matches
	matches=$(git show "${ref}:${file}" 2>/dev/null | grep -nE "${grep_args[@]}" 2>/dev/null || true)
	[ -z "$matches" ] && return 0

	local line lineno match label
	while IFS= read -r line; do
		[ -z "$line" ] && continue
		lineno="${line%%:*}"
		match="${line#*:}"

		for ((i = 0; i < ${#LABELS[@]}; i += 2)); do
			if echo "$match" | grep -qE "${LABELS[$i]}" 2>/dev/null; then
				label="${LABELS[$((i + 1))]}"
				break
			fi
		done

		local snippet="${match:0:150}"
		snippet="${snippet#"${snippet%%[![:space:]]*}"}"
		echo -e "  ${RED}${file}:${lineno}${NC} → ${YELLOW}${label}${NC}"
		echo -e "  ${snippet}"
		found=1
	done <<< "$matches"
	return "$found"
}

skip_file() {
	[[ "$1" == hooks/* ]] && return 0
	return 1
}

scan_staged() {
	local found=0 file
	while IFS= read -r file; do
		[ -z "$file" ] && continue
		skip_file "$file" && continue
		scan_content "" "$file" || found=1
	done <<< "$1"
	return "$found"
}

scan_committed() {
	local ref="$1" found=0 file
	while IFS= read -r file; do
		[ -z "$file" ] && continue
		skip_file "$file" && continue
		scan_content "$ref" "$file" || found=1
	done <<< "$2"
	return "$found"
}
