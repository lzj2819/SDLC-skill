#!/usr/bin/env bash
#
# DevForge SDLC Skill Chain — Updater (macOS/Linux)
#
# Usage: ./update.sh
#
# This script updates DevForge by running git pull in the clone directory.
# Since skills are symlinked, no re-installation is needed.
#

set -euo pipefail

INSTALL_DIR="${HOME}/.claude/devforge-skills"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }

if [[ ! -d "${INSTALL_DIR}/.git" ]]; then
    echo "DevForge is not installed. Please run install.sh first."
    exit 1
fi

info "Checking for updates..."
cd "${INSTALL_DIR}"

# Fetch latest changes
git fetch origin main

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [[ "$LOCAL" == "$REMOTE" ]]; then
    ok "DevForge is already up to date."
    exit 0
fi

info "New version available. Updating..."
git pull origin main

ok "DevForge updated successfully!"
ok "Current version: $(git log --oneline -1)"

echo ""
echo "Symlinks are automatically pointing to the new code."
echo "Restart Claude Code or run /reload to use the updated skills."
