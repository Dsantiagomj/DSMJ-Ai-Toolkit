#!/usr/bin/env bash
#
# dsmj-ai-toolkit installer
# Usage: curl -fsSL https://raw.githubusercontent.com/dsantiagomj/dsmj-ai-toolkit/main/install.sh | bash

set -euo pipefail

VERSION="1.0.0"
TOOLKIT_DIR="$HOME/.dsmj-ai-toolkit"
REPO_URL="https://github.com/dsantiagomj/dsmj-ai-toolkit"
GITHUB_API="https://api.github.com/repos/dsantiagomj/dsmj-ai-toolkit"

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

# Check if running on macOS or Linux
check_os() {
    case "$OSTYPE" in
        darwin*)  OS="macos" ;;
        linux*)   OS="linux" ;;
        *)
            error "Unsupported OS: $OSTYPE"
            error "This installer only supports macOS and Linux"
            exit 1
            ;;
    esac
}

# Check for required commands
check_requirements() {
    local missing_deps=()

    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi

    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        error "Please install them and try again"
        exit 1
    fi
}

# Get latest release version from GitHub
get_latest_version() {
    if command -v curl &> /dev/null; then
        local latest=$(curl -fsSL "$GITHUB_API/releases/latest" 2>/dev/null | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
        if [ -n "$latest" ]; then
            echo "$latest"
        else
            echo "main"
        fi
    else
        echo "main"
    fi
}

# Main installation function
install_toolkit() {
    echo ""
    info "Installing dsmj-ai-toolkit v${VERSION}..."
    echo ""

    # Check if already installed
    if [ -d "$TOOLKIT_DIR" ]; then
        warn "Toolkit already installed at $TOOLKIT_DIR"
        read -p "Reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Installation cancelled"
            exit 0
        fi
        info "Removing existing installation..."
        rm -rf "$TOOLKIT_DIR"
    fi

    # Create temporary directory
    local temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT

    info "Downloading toolkit..."

    # Clone repository
    local branch=$(get_latest_version)
    if git clone --depth 1 --branch "$branch" "$REPO_URL" "$temp_dir" 2>/dev/null || \
       git clone --depth 1 "$REPO_URL" "$temp_dir" 2>/dev/null; then
        success "Downloaded successfully"
    else
        error "Failed to download toolkit from $REPO_URL"
        exit 1
    fi

    # Create toolkit directory
    mkdir -p "$TOOLKIT_DIR"

    # Copy files
    info "Installing files to $TOOLKIT_DIR..."
    cp -r "$temp_dir/templates" "$TOOLKIT_DIR/" 2>/dev/null || true
    cp -r "$temp_dir/agents" "$TOOLKIT_DIR/"
    cp -r "$temp_dir/skills" "$TOOLKIT_DIR/"
    cp -r "$temp_dir/bin" "$TOOLKIT_DIR/"
    cp -r "$temp_dir/.dsmj-ai" "$TOOLKIT_DIR/" 2>/dev/null || true

    # Make CLI executable
    chmod +x "$TOOLKIT_DIR/bin/dsmj-ai"

    success "Files installed"

    # Add to PATH
    local shell_config=""
    local shell_name=""

    if [ -n "${BASH_VERSION:-}" ] || [ -f "$HOME/.bashrc" ]; then
        shell_config="$HOME/.bashrc"
        shell_name="bash"
    elif [ -n "${ZSH_VERSION:-}" ] || [ -f "$HOME/.zshrc" ]; then
        shell_config="$HOME/.zshrc"
        shell_name="zsh"
    fi

    if [ -n "$shell_config" ]; then
        if ! grep -q "dsmj-ai-toolkit" "$shell_config" 2>/dev/null; then
            info "Adding to PATH in $shell_config..."
            echo "" >> "$shell_config"
            echo "# dsmj-ai-toolkit" >> "$shell_config"
            echo 'export PATH="$HOME/.dsmj-ai-toolkit/bin:$PATH"' >> "$shell_config"
            success "Added to PATH"
        else
            info "Already in PATH"
        fi
    fi

    echo ""
    success "Installation complete!"
    echo ""
    info "Next steps:"
    echo "  1. Restart your terminal or run: source $shell_config"
    echo "  2. Navigate to your project directory"
    echo "  3. Run: dsmj-ai init"
    echo ""
    info "For help: dsmj-ai --help"
    info "Repository: $REPO_URL"
    echo ""
}

# Main execution
main() {
    check_os
    check_requirements
    install_toolkit
}

main "$@"
