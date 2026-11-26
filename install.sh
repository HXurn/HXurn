#!/data/data/com.termux/files/usr/bin/bash

set -e

C=$'\033[36m'
G=$'\033[32m'
R=$'\033[0m'

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$SOURCE_DIR/dashboard.sh"
TARGET="$HOME/.config/hxurn/dashboard.sh"

printf '%s\n' "╭────────────────────────────────────╮"
printf '│          HXurn Installer           │\n'
printf '╰────────────────────────────────────╯\n\n'

# Check Termux
if [[ -z "${PREFIX:-}" || ! -d "$PREFIX" ]]; then
    printf '%sError:%s This installer is intended for Termux.\n' "$R" "$R"
    exit 1
fi

# Check source file
if [[ ! -f "$SOURCE" || ! -s "$SOURCE" ]]; then
    printf '%sError:%s dashboard.sh missing or empty.\n' "$R" "$R"
    exit 1
fi

# Create configuration directory
mkdir -p "$HOME/.config/hxurn"

# Backup existing dashboard if it differs
if [[ -f "$TARGET" ]] && ! cmp -s "$SOURCE" "$TARGET"; then
    BACKUP="${TARGET}.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$TARGET" "$BACKUP"
    printf '%sBackup created:%s %s\n' "$C" "$R" "$BACKUP"
fi

# Install dashboard
cp "$SOURCE" "$TARGET"
chmod 755 "$TARGET"

printf '\n%sHXurn installed successfully!%s\n' "$G" "$R"
printf 'Location: %s\n' "$TARGET"
