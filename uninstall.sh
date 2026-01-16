#!/usr/bin/env bash
#
# dsmj-ai-toolkit uninstaller
# Usage: curl -fsSL https://raw.githubusercontent.com/dsantiagomj/dsmj-ai-toolkit/main/uninstall.sh | bash
#        or: bash ~/.dsmj-ai-toolkit/uninstall.sh

set -euo pipefail

TOOLKIT_DIR="$HOME/.dsmj-ai-toolkit"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}ℹ${NC}  $1"
}

success() {
    echo -e "${GREEN}✓${NC}  $1"
}

warn() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

error() {
    echo -e "${RED}✗${NC}  $1" >&2
}

uninstall_toolkit() {
    echo ""
    info "Uninstalling dsmj-ai-toolkit..."
    echo ""

    if [ ! -d "$TOOLKIT_DIR" ]; then
        warn "Toolkit not found at $TOOLKIT_DIR"
        info "Nothing to uninstall"
        exit 0
    fi

    warn "This will remove:"
    echo "  - $TOOLKIT_DIR (global toolkit installation)"
    echo "  - PATH entry in shell config"
    echo ""
    warn "This will NOT remove:"
    echo "  - .claude/ directories in your projects"
    echo "  - Project-specific configurations"
    echo ""

    read -p "Continue with uninstallation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Uninstallation cancelled"
        exit 0
    fi

    # Remove toolkit directory
    info "Removing $TOOLKIT_DIR..."
    rm -rf "$TOOLKIT_DIR"
    success "Removed toolkit files"

    # Remove from PATH
    local removed=false
    for config in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$config" ]; then
            if grep -q "dsmj-ai-toolkit" "$config" 2>/dev/null; then
                info "Removing PATH entry from $config..."
                # Create backup
                cp "$config" "${config}.backup"
                # Remove the dsmj-ai-toolkit section
                sed -i.tmp '/# dsmj-ai-toolkit/,/export PATH.*dsmj-ai-toolkit/d' "$config"
                rm -f "${config}.tmp"
                success "Removed from $config (backup: ${config}.backup)"
                removed=true
            fi
        fi
    done

    if [ "$removed" = false ]; then
        info "No PATH entries found to remove"
    fi

    echo ""
    success "Uninstallation complete!"
    echo ""
    info "To reinstall:"
    echo "  curl -fsSL https://raw.githubusercontent.com/dsantiagomj/dsmj-ai-toolkit/main/install.sh | bash"
    echo ""
}

main() {
    uninstall_toolkit
}

main "$@"
