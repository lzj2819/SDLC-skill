#!/usr/bin/env bash
#
# DevForge SDLC Skill Chain — One-Click Installer (macOS/Linux)
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/lzj2819/DevForge-skill/main/install.sh | bash
#   Or locally: ./install.sh
#
# This installer uses a symlink-based approach:
#   1. Clones the repo once to ~/.claude/devforge-skills/
#   2. Creates symlinks in ~/.claude/skills/ pointing to each skill directory
#   3. Updates are done via "git pull" in the clone directory — no re-download needed
#

set -euo pipefail

REPO_URL="${DEVFORGE_REPO_URL:-https://github.com/lzj2819/DevForge-skill.git}"
INSTALL_DIR="${HOME}/.claude/devforge-skills"
SKILLS_DIR="${HOME}/.claude/skills"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

print_banner() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║          DevForge SDLC Skill Chain Installer v1.3            ║"
    echo "║     Symlink-based install — update with a single git pull    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
}

detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macOS";;
        Linux*)     echo "Linux";;
        CYGWIN*|MINGW*|MSYS*) echo "Windows";;
        *)          echo "Unknown";;
    esac
}

check_prerequisites() {
    info "Checking prerequisites..."

    if ! command -v git &>/dev/null; then
        err "Git is not installed. Please install Git first."
        exit 1
    fi
    ok "Git is installed"

    if ! command -v python3 &>/dev/null && ! command -v python &>/dev/null; then
        warn "Python is not installed. Some validation scripts may not work."
    else
        ok "Python is installed"
    fi
}

ensure_dirs() {
    info "Creating directories..."
    mkdir -p "${INSTALL_DIR}"
    mkdir -p "${SKILLS_DIR}"
    ok "Directories ready"
}

clone_or_update_repo() {
    if [[ -d "${INSTALL_DIR}/.git" ]]; then
        info "Existing installation found at ${INSTALL_DIR}"
        info "Updating via git pull..."
        cd "${INSTALL_DIR}"
        git pull origin main
        ok "Updated to latest version"
    else
        info "Cloning DevForge repository..."
        if git clone "${REPO_URL}" "${INSTALL_DIR}" 2>/dev/null; then
            ok "Repository cloned to ${INSTALL_DIR}"
        else
            warn "Remote clone failed. Falling back to local copy..."
            local script_dir
            script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
            if [[ -d "${script_dir}/devforge-requirement-analysis" ]]; then
                mkdir -p "${INSTALL_DIR}"
                tar -C "${script_dir}" --exclude='.git' --exclude='.claude' -cf - . | tar -C "${INSTALL_DIR}" -xf -
                ok "Copied local repo to ${INSTALL_DIR}"
            else
                err "Cannot find DevForge source. Please run this script from the project root or ensure remote repo is accessible."
                exit 1
            fi
        fi
    fi
}

remove_old_symlinks() {
    # Clean up any existing DevForge symlinks to avoid stale links
    local skills=(
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
        ai-agent-design
        data-pipeline-design
        mobile-app-design
    )

    for skill in "${skills[@]}"; do
        local link="${SKILLS_DIR}/${skill}"
        if [[ -L "${link}" ]]; then
            rm "${link}"
        fi
    done
}

create_symlinks() {
    info "Creating skill symlinks in ${SKILLS_DIR}..."

    local core_skills=(
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
        devforge-threat-modeling
        devforge-data-pipeline
    )

    local count=0

    # Link core skills
    for skill in "${core_skills[@]}"; do
        local src="${INSTALL_DIR}/${skill}"
        local dst="${SKILLS_DIR}/${skill}"

        if [[ -d "${src}" ]]; then
            ln -sfn "${src}" "${dst}"
            ok "Linked: ${skill}"
            ((count++))
        else
            warn "Skill directory not found: ${skill}"
        fi
    done

    # Link extension skills (flatten into skills dir)
    local extensions=(
        ai-agent-design
        data-pipeline-design
        mobile-app-design
    )

    for ext in "${extensions[@]}"; do
        local src="${INSTALL_DIR}/extensions/${ext}"
        local dst="${SKILLS_DIR}/${ext}"

        if [[ -d "${src}" ]]; then
            ln -sfn "${src}" "${dst}"
            ok "Linked: extensions/${ext} → ${ext}"
            ((count++))
        else
            warn "Extension directory not found: ${ext}"
        fi
    done

    ok "${count} skills linked successfully"
}

validate_installation() {
    info "Validating installation..."

    cd "${INSTALL_DIR}"
    python3 scripts/package-plugin.py --mode all --output ./dist >/dev/null 2>&1 || true

    local skill_count=0
    for dir in "${SKILLS_DIR}"/*/; do
        if [[ -f "${dir}/SKILL.md" ]]; then
            ((skill_count++))
        fi
    done

    if [[ ${skill_count} -ge 10 ]]; then
        ok "Validation passed: ${skill_count} skills detected"
    else
        warn "Only ${skill_count} skills detected (expected 10+). Check symlinks."
    fi
}

print_next_steps() {
    local os="$(detect_os)"

    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                  Installation Complete!                      ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📁 Repository cloned to:  ${INSTALL_DIR}"
    echo "🔗 Skills linked in:     ${SKILLS_DIR}"
    echo ""
    echo "🚀 Next steps:"
    echo "   1. Restart Claude Code or run: /reload"
    echo "   2. Verify with: /skill list"
    echo "   3. Start your first project: \"我想做一个 [产品想法]\""
    echo ""
    echo "🔄 To update:"
    echo "   cd ${INSTALL_DIR} && git pull"
    echo "   Or run: ${INSTALL_DIR}/update.sh"
    echo ""
    echo "🗑️  To uninstall:"
    echo "   ${INSTALL_DIR}/uninstall.sh"
    echo ""
    echo "📖 Documentation: https://github.com/lzj2819/DevForge-skill"
    echo ""
}

remove_temp_installer() {
    # Auto-remove the downloaded install.sh if it's outside the install directory
    local script_path
    script_path="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
    local installed_script="${INSTALL_DIR}/install.sh"
    if [[ "${script_path}" != "${installed_script}" && -f "$0" ]]; then
        rm -f "$0" 2>/dev/null || true
    fi
}

main() {
    print_banner
    check_prerequisites
    ensure_dirs
    clone_or_update_repo
    remove_old_symlinks
    create_symlinks
    validate_installation
    print_next_steps
    remove_temp_installer
}

main "$@"
