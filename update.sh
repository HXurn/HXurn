#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

C=$'\033[36m'
G=$'\033[32m'
R=$'\033[0m'

URL="https://raw.githubusercontent.com/HXurn/HXurn/main/dashboard.sh"
TARGET="$HOME/.config/hxurn/dashboard.sh"

printf '%s\n' "╭────────────────────────────────────╮"
printf '│           HXurn Updater           │\n'
printf '╰────────────────────────────────────╯\n\n'

# Check Termux
if [[ -z "${PREFIX:-}" || ! -d "$PREFIX" ]]; then
    printf '%sError:%s This updater is intended for Termux.\n' "$R" "$R"
    exit 1
fi

# Check curl
if ! command -v curl >/dev/null 2>&1; then
    printf '%sError:%s curl is required.\n' "$R" "$R"
    exit 1
fi

# Create configuration directory
mkdir -p "$(dirname "$TARGET")"

# Download latest dashboard to temporary file
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

printf 'Checking GitHub for updates...\n'

if ! curl -fsSL --retry 2 "$URL" -o "$TEMP_FILE"; then
    printf '%sError:%s Download failed.\n' "$R" "$R"
    exit 1
fi

# Check downloaded file
if [[ ! -s "$TEMP_FILE" ]]; then
    printf '%sError:%s Downloaded file is empty.\n' "$R" "$R"
    exit 1
fi

if ! bash -n "$TEMP_FILE"; then
    printf '%sError:%s Downloaded script has invalid syntax.\n' "$R" "$R"
    exit 1
fi

# Skip if already up to date
if [[ -f "$TARGET" ]] && cmp -s "$TEMP_FILE" "$TARGET"; then
    printf '\n%sHXurn is already up to date.%s\n' "$G" "$R"
    exit 0
fi

# Backup existing dashboard
if [[ -f "$TARGET" ]]; then
    BACKUP="${TARGET}.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$TARGET" "$BACKUP"
    printf '%sBackup created:%s %s\n' "$C" "$R" "$BACKUP"
fi

# Install update
cp "$TEMP_FILE" "$TARGET"
chmod 755 "$TARGET"

printf '\n%sHXurn updated successfully!%s\n' "$G" "$R"
printf 'Location: %s\n' "$TARGET"
