#!/bin/bash

set -e

# Configuration
REPO="${OPENCODE_REPO:-Ridter/opencode}"
INSTALL_DIR="${OPENCODE_INSTALL_DIR:-/usr/local/bin}"
BINARY_NAME="opencode"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "darwin";;
        CYGWIN*|MINGW*|MSYS*) echo "windows";;
        *)          error "Unsupported operating system: $(uname -s)";;
    esac
}

# Detect architecture
detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)   echo "x64";;
        arm64|aarch64)  echo "arm64";;
        *)              error "Unsupported architecture: $(uname -m)";;
    esac
}

# Get latest release version
get_latest_version() {
    local version
    version=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$version" ] || [ "$version" == "null" ]; then
        error "Failed to fetch latest version from GitHub"
    fi
    
    echo "$version"
}

# Main installation function
main() {
    info "OpenCode Installer"
    echo ""
    
    # Detect system
    local os=$(detect_os)
    local arch=$(detect_arch)
    
    info "Detected OS: $os"
    info "Detected Architecture: $arch"
    
    # Get version
    local version="${OPENCODE_VERSION:-$(get_latest_version)}"
    info "Installing version: $version"
    
    # Construct download URL
    local binary_suffix=""
    if [ "$os" == "windows" ]; then
        binary_suffix=".exe"
    fi
    
    local binary_name="opencode-${os}-${arch}${binary_suffix}"
    local download_url="https://github.com/${REPO}/releases/download/${version}/${binary_name}"
    
    info "Download URL: $download_url"
    
    # Create temp directory
    local tmp_dir=$(mktemp -d)
    trap "rm -rf $tmp_dir" EXIT
    
    # Download binary
    info "Downloading $binary_name..."
    if ! curl -fsSL "$download_url" -o "$tmp_dir/$BINARY_NAME"; then
        error "Failed to download binary. Please check if the release exists."
    fi
    
    # Make executable
    chmod +x "$tmp_dir/$BINARY_NAME"
    
    # Install
    info "Installing to $INSTALL_DIR/$BINARY_NAME..."
    
    if [ -w "$INSTALL_DIR" ]; then
        mv "$tmp_dir/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
    else
        warn "Need sudo to install to $INSTALL_DIR"
        sudo mv "$tmp_dir/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
    fi
    
    # Verify installation
    if command -v opencode &> /dev/null; then
        info "Installation successful!"
        echo ""
        info "Run 'opencode --help' to get started"
    else
        warn "Installation completed, but 'opencode' is not in PATH"
        warn "You may need to add $INSTALL_DIR to your PATH"
        echo ""
        echo "Add this to your shell profile:"
        echo "  export PATH=\"\$PATH:$INSTALL_DIR\""
    fi
}

# Run main function
main "$@"
