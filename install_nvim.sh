#!/usr/bin/env bash

set -e

RELEASE=""

# Usage function
usage() {
    echo "Usage: $0 -r RELEASE"
    echo "  -r RELEASE    Specify the Neovim release to install"
    echo "  --help        Show this help message"
    exit 1
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -r|--release)
            if [[ -z "$2" || "$2" == -* ]]; then
                echo "Error: -r requires a release argument"
                usage
            fi
            RELEASE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate arguments
if [[ -z "$RELEASE" ]]; then
    echo "Error: Release (-r) is required"
    usage
fi

ensure_deps_installed() {
    echo "🔍 Ensuring dependencies are installed..."
    # Check for required commands
    for cmd in wget tar; do
        if ! command -v $cmd &> /dev/null; then
            echo "Error: $cmd is not installed."
            exit 1
        fi
    done
}

install_nvim() {
    # Download the tarball
    echo "📥 Downloading Neovim release $RELEASE..."
    wget -P /tmp "https://github.com/neovim/neovim/releases/download/v$RELEASE/nvim-linux-x86_64.tar.gz"

    # Unpack the tarball
    echo "📦 Unpacking Neovim release $RELEASE..."
    tar -xzf /tmp/nvim-linux-x86_64.tar.gz -C /opt

    # create a symlink
    echo "🔗 Creating symlink for Neovim..."
    ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

    # Clean up
    echo "🧹 Cleaning up..."
    rm /tmp/nvim-linux-x86_64.tar.gz
    
    echo "✅ Neovim $RELEASE installation complete! 🎉"
}

main() {
    ensure_deps_installed
    install_nvim
}

main