#!/bin/bash
set -e

if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
fi

# Installation procedure
NVIM_VERSION_TARGET="0.10.0"

function install_nvim_binary {
    set -e

    if [ -z "$NVIM_VERSION_TARGET" ]; then
        echo "NVIM_VERSION_TARGET not set"
        return 1
    fi

    echo "Installing/updating Neovim $NVIM_VERSION_TARGET..."

    local NVIM_URL="https://github.com/neovim/neovim/releases/download/v$NVIM_VERSION_TARGET/nvim.appimage"
    local NVIM_URL="https://github.com/neovim/neovim-releases/releases/download/v$NVIM_VERSION_TARGET/nvim.appimage"
    local NVIM_BIN="$HOME/.local/bin/nvim"
    local NVIM_APPIMAGE="$NVIM_BIN.appimage"

    # Check if Neovim is installed, and if it's the correct version, else download it
    if [ ! -f "$NVIM_BIN" ]; then
        echo 'Neovim not found, downloading...'
        wget "$NVIM_URL" -O "$NVIM_APPIMAGE"
    else
        echo 'Neovim found, checking version...'
        local NVIM_VERSION_CURRENT="$($NVIM_BIN --version | head -n 1 | cut -d ' ' -f 2)"
        if [ "$NVIM_VERSION_CURRENT" != "v$NVIM_VERSION_TARGET" ]; then
            echo "> Incorrect version: $NVIM_VERSION_CURRENT"
            rm -rf "$NVIM_BIN"
            echo "> Downloading version: v$NVIM_VERSION_TARGET"

        echo "> $NVIM_URL"
            wget "$NVIM_URL" -O "$NVIM_APPIMAGE"
        else
            echo "> Correct version: $NVIM_VERSION_CURRENT"
        fi
    fi

    chmod u+x "$NVIM_BIN.appimage"

    if [ ! -L "$NVIM_BIN" ]; then
        echo "> Creating symbolic link to $NVIM_BIN from appimage"
        ln -s "$NVIM_BIN.appimage" "$NVIM_BIN"
    fi

    return 0
}

NVIM_ROOT="$HOME/.config/nvim"
NVIM_PREF="$HOME/preferences/config/nvim"

install_nvim_binary
