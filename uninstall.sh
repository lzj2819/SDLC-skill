#!/usr/bin/env bash
#
# DevForge SDLC Skill Chain — Uninstaller (macOS/Linux)
#
# Usage: ./uninstall.sh
#

set -euo pipefail

INSTALL_DIR="${HOME}/.claude/devforge-skills"
SKILLS_DIR="${HOME}/.claude/skills"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }

read -p "Are you sure you want to uninstall DevForge? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    info "Uninstall cancelled."
    exit 0
fi

# Remove symlinks
skills=(
    devforge-requirement-analysis
    devforge-architecture-design
    devforge-architecture-validation
    devforge-design-review
    devforge-project-scaffolding
    devforge-module-design
    devforge-test-execution
    devforge-iteration-planning
    devforge-visualization
    devforge-ops-ready
    devforge-debug-assistant
    devforge-security-audit
    context-compression
    ai-agent-design
    data-pipeline-design
    mobile-app-design
)

info "Removing skill symlinks..."
for skill in "${skills[@]}"; do
    link="${SKILLS_DIR}/${skill}"
    if [[ -L "${link}" ]]; then
        rm "${link}"
        info "Removed symlink: ${skill}"
    fi
done

# Optionally remove the cloned repo
read -p "Remove the cloned repository at ${INSTALL_DIR}? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "${INSTALL_DIR}"
    info "Removed ${INSTALL_DIR}"
fi

info "Uninstall complete. Restart Claude Code or run /reload."
