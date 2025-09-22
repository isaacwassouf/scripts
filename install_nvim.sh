#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd -- $(dirname "${BASH_SOURCE[0]}") && pwd)

RELEASE=""
CONFIG=""

# Usage function
usage() {
    echo "Usage: $0 [-r RELEASE]"
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
        -c|--config)
            if [[ -z "$2" || "$2" == -* ]]; then
                echo "Error: -c requires a config name argument"
                usage
            fi
            CONFIG="$2"
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
    RELEASE="stable"
    echo "Release was not specified, defaulting to stable"
else
    # add v prefix if not present
    if [[ "$RELEASE" != v* ]]; then
        RELEASE="v$RELEASE"
    fi
fi

install_config() {
    # check if the config exists in the configs.json
    if jq '.configs | has("'$CONFIG'")' $SCRIPT_DIR/configs.json | grep -q "false"; then
        echo "Config $CONFIG does not exist in configs.json"
        exit 1
    fi

    CONFIG_REPO=$(jq '.configs."'$CONFIG'"' $SCRIPT_DIR/configs.json | tr -d '"')

    # create the config directory
    mkdir -p $HOME/.config

    # check if a config exists
    if [[ -d $HOME/.config/nvim ]]; then
        echo "🔗 A config exists in $HOME/.config/nvim, backing up to nvim.backup"
        mv $HOME/.config/nvim $HOME/.config/nvim.backup
    fi

    # clone the nvim config into the config directory
    echo "🔗 Cloning $CONFIG config..."
    git clone -q $CONFIG_REPO $HOME/.config/nvim

    echo "✅ $CONFIG config installed successfully! 🎉"
}

ensure_deps_installed() {
    echo "🔍 Ensuring dependencies are installed..."
    # Check for required commands
    for cmd in wget tar git jq; do
        if ! command -v $cmd &> /dev/null; then
            echo "Error: $cmd is not installed."
            exit 1
        fi
    done
}

install_nvim() {
    # Download the tarball
    echo "📥 Downloading Neovim release $RELEASE..."
    wget -P /tmp "https://github.com/neovim/neovim/releases/download/$RELEASE/nvim-linux-x86_64.tar.gz"

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

    if [[ -n "$CONFIG" ]]; then
        install_config
    fi
}

main
