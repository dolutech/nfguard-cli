#!/usr/bin/env bash
# NFGuard v0.1.0 — Installation Script
# Usage: curl -sL https://raw.githubusercontent.com/dolutech/nfguard-cli/main/install.sh | sudo bash
#
# Downloads, installs NFGuard to /opt/nfguard/, and creates a symlink at /usr/local/bin/nfguard.
# Creates default configuration in ~/.nfguard/ for the invoking user.

set -euo pipefail

VERSION="0.1.0"
TARBALL="nfguard-${VERSION}-linux-amd64.tar.gz"
DOWNLOAD_URL="https://github.com/dolutech/nfguard-cli/releases/download/v${VERSION}/${TARBALL}"
INSTALL_DIR="/opt/nfguard"
SYMLINK="/usr/local/bin/nfguard"
TMP_TARBALL="/tmp/${TARBALL}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }

show_help() {
    cat <<EOF
NFGuard v${VERSION} — Installation Script

Usage:
    curl -sL https://raw.githubusercontent.com/dolutech/nfguard-cli/main/install.sh | sudo bash
    sudo bash install.sh                Install NFGuard
    bash install.sh --help              Show this help
    sudo bash install.sh --uninstall    Remove NFGuard

Requirements:
    - Linux x86_64 (amd64)
    - Root/sudo access
    - curl (for downloading the release)
EOF
    exit 0
}

uninstall() {
    info "Uninstalling NFGuard..."

    if [[ -L "$SYMLINK" ]]; then
        rm -f "$SYMLINK"
        ok "Removed symlink $SYMLINK"
    fi

    if [[ -d "$INSTALL_DIR" ]]; then
        rm -rf "$INSTALL_DIR"
        ok "Removed $INSTALL_DIR"
    fi

    info "User config at ~/.nfguard/ was NOT removed (preserving your settings)."
    ok "NFGuard uninstalled."
    exit 0
}

# --- Parse arguments ---
for arg in "$@"; do
    case "$arg" in
        --help|-h)    show_help ;;
        --uninstall)  uninstall ;;
    esac
done

# --- OS detection ---
OS="$(uname -s)"
ARCH="$(uname -m)"

if [[ "$OS" != "Linux" ]]; then
    error "This installer only supports Linux."
    error "Detected OS: $OS"
    if [[ "$OS" == "Darwin" ]]; then
        error "macOS support is planned for a future release."
    fi
    exit 1
fi

if [[ "$ARCH" != "x86_64" ]]; then
    error "This build only supports x86_64 (amd64) architecture."
    error "Detected architecture: $ARCH"
    if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
        error "ARM64 support is planned for a future release."
    fi
    exit 1
fi

info "Detected: Linux $ARCH"

# --- Root check ---
if [[ $EUID -ne 0 ]]; then
    error "This installer requires root privileges."
    error "Run with: curl -sL https://raw.githubusercontent.com/dolutech/nfguard-cli/main/install.sh | sudo bash"
    exit 1
fi

# Resolve the real user (even when run via sudo)
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

if [[ -z "$REAL_HOME" ]]; then
    error "Could not determine home directory for user '$REAL_USER'."
    exit 1
fi

# --- Check for curl ---
if ! command -v curl &>/dev/null; then
    error "curl is required but not installed."
    error "Install it with: sudo pacman -S curl  (Arch) / sudo apt install curl  (Debian/Ubuntu)"
    exit 1
fi

# --- Download tarball ---
info "Downloading NFGuard v${VERSION} ..."
if curl -fSL "$DOWNLOAD_URL" -o "$TMP_TARBALL" 2>&1; then
    ok "Downloaded ${TARBALL}"
else
    error "Failed to download from: $DOWNLOAD_URL"
    error "Check your internet connection or try again later."
    rm -f "$TMP_TARBALL"
    exit 1
fi

# Verify the download is a valid gzip file
if ! file "$TMP_TARBALL" | grep -q "gzip"; then
    error "Downloaded file is not a valid tarball (possibly a 404 page)."
    error "URL: $DOWNLOAD_URL"
    rm -f "$TMP_TARBALL"
    exit 1
fi

# --- Install ---
info "Installing NFGuard to $INSTALL_DIR ..."

# Remove previous installation if it exists
if [[ -d "$INSTALL_DIR" ]]; then
    warn "Previous installation found at $INSTALL_DIR — removing..."
    rm -rf "$INSTALL_DIR"
fi

# Extract
mkdir -p "$INSTALL_DIR"
tar xzf "$TMP_TARBALL" -C /opt/
ok "Extracted to $INSTALL_DIR"

# Clean up downloaded tarball
rm -f "$TMP_TARBALL"

# Set permissions on the main executable
chmod +x "${INSTALL_DIR}/nfguard"
ok "Set executable permissions"

# Make bundled binaries executable
if [[ -d "${INSTALL_DIR}/nfguard/_bundled/bin" ]]; then
    chmod +x "${INSTALL_DIR}/nfguard/_bundled/bin/"* 2>/dev/null || true
    ok "Set permissions on bundled binaries"
fi

# --- Create symlink ---
if [[ -L "$SYMLINK" || -f "$SYMLINK" ]]; then
    rm -f "$SYMLINK"
fi
ln -s "${INSTALL_DIR}/nfguard" "$SYMLINK"
ok "Created symlink: $SYMLINK -> ${INSTALL_DIR}/nfguard"

# --- User configuration ---
NFGUARD_HOME="${REAL_HOME}/.nfguard"

if [[ ! -d "$NFGUARD_HOME" ]]; then
    info "Creating configuration directory: $NFGUARD_HOME"
    mkdir -p "$NFGUARD_HOME"

    # config.yaml — defaults
    cat > "${NFGUARD_HOME}/config.yaml" <<'CONFIGEOF'
# NFGuard Configuration
# See: nfguard --help

# Default provider to use (must match a name in providers.yaml)
default_provider: openrouter

# Default model for the orchestrator agent
default_model: anthropic/claude-sonnet-4-20250514

# Log level: DEBUG, INFO, WARNING, ERROR
log_level: INFO
CONFIGEOF

    # providers.yaml — template for user to fill in
    cat > "${NFGUARD_HOME}/providers.yaml" <<'PROVEOF'
# NFGuard Provider Configuration
# ================================
# Add your AI provider API keys here.
# This file should have restricted permissions (chmod 600).
#
# Example configuration:
#
# providers:
#   openrouter:
#     base_url: https://openrouter.ai/api/v1
#     api_key: sk-or-xxxxxxxxxxxxxxxxxxxx
#     default_model: anthropic/claude-sonnet-4-20250514
#
#   openai:
#     base_url: https://api.openai.com/v1
#     api_key: sk-xxxxxxxxxxxxxxxxxxxxxxxx
#     default_model: gpt-4o
#
# Uncomment and fill in your provider details below:

providers: {}
PROVEOF

    # Secure permissions
    chmod 700 "$NFGUARD_HOME"
    chmod 600 "${NFGUARD_HOME}/config.yaml"
    chmod 600 "${NFGUARD_HOME}/providers.yaml"

    # Set ownership to the real user
    chown -R "${REAL_USER}:${REAL_USER}" "$NFGUARD_HOME"
    ok "Created config directory: $NFGUARD_HOME"
else
    info "Config directory already exists: $NFGUARD_HOME (skipping)"
fi

# --- Done ---
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  NFGuard v${VERSION} installed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "  Executable:  $SYMLINK"
echo "  Install dir: $INSTALL_DIR"
echo "  Config dir:  $NFGUARD_HOME"
echo ""
echo -e "${CYAN}First steps:${NC}"
echo "  1. Edit ${NFGUARD_HOME}/providers.yaml and add your API key"
echo "  2. Run: nfguard"
echo "  3. The setup wizard will guide you through initial configuration"
echo ""
echo -e "${CYAN}Uninstall:${NC}"
echo "  curl -sL https://raw.githubusercontent.com/dolutech/nfguard-cli/main/install.sh | sudo bash -s -- --uninstall"
echo ""
