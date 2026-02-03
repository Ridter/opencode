#!/bin/bash

set -e

# Configuration
REPO="${OPENCODE_REPO:-Ridter/opencode}"
INSTALL_DIR="${OPENCODE_INSTALL_DIR:-$HOME/.opencode/bin}"
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
        echo "" # Return empty string, let caller handle the error
        return 1
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
    local version="${VERSION:-${OPENCODE_VERSION:-}}"
    if [ -z "$version" ]; then
        version=$(get_latest_version)
        if [ -z "$version" ]; then
            error "Failed to fetch latest version from GitHub. Please check if releases exist at https://github.com/${REPO}/releases or specify VERSION manually."
        fi
    fi
    info "Installing version: $version"
    
    # Construct download URL
    local binary_suffix=""
    if [ "$os" == "windows" ]; then
        binary_suffix=".exe"
    fi
    
    local binary_name="opencode-${os}-${arch}${binary_suffix}"
    # Ensure version has 'v' prefix for GitHub release URL
    local version_tag="${version}"
    [[ ! "$version_tag" =~ ^v ]] && version_tag="v${version_tag}"
    local download_url="https://github.com/${REPO}/releases/download/${version_tag}/${binary_name}"
    
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
    
    mkdir -p "$INSTALL_DIR"
    mv "$tmp_dir/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
    
    # Verify installation
    if command -v opencode &> /dev/null; then
        info "Installation successful!"
        echo ""
        info "Run 'opencode --help' to get started"
    else
        warn "Installation completed, but 'opencode' is not in PATH"
        echo ""
        echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        echo "  export PATH=\"\$HOME/.opencode/bin:\$PATH\""
        echo ""
        echo "Then restart your shell or run:"
        echo "  source ~/.bashrc  # or ~/.zshrc"
    fi
}

# Run main function
main "$@"
