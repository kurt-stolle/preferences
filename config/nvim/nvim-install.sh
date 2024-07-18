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

function install_nvim_venv {
    set -e
    echo 'Checking Python environment...'

    mkdir -p "$HOME/.venvs"
    local VENV_PATH="$HOME/.venvs/nvim"
    if [ ! -d "$VENV_PATH" ]; then
        echo "> Creating virtual environment"

        local PYTHON_BASE=python3
        if command -v conda &> /dev/null; then
            echo "> Conda found, using Python from 'nvim' environment"
            if [ `conda env list | grep -q nvim` -ne 0 ]; then
                conda create --name nvim python==3.12 -n
            fi
            PYTHON_BASE='conda run -n nvim python'
        fi

        $PYTHON_BASE -m venv --prompt nvim --symlinks "$VENV_PATH"
    else
        echo "> Virtual environment exists"
    fi
    PYTHON_NVIM="$VENV_PATH/bin/python"

    echo '> Upgrading pip'
    $PYTHON_NVIM -m pip install --upgrade pip

    echo '> Upgrading Python build utilities'
    $PYTHON_NVIM -m pip install --upgrade setuptools wheel

    echo '> Installing Python packages'
    $PYTHON_NVIM -m pip install --upgrade pynvim jupyter_client cairosvg pnglatex matplotlib plotly kaleido pyperclip

    echo '> Installing Hererocks'
    $PYTHON_NVIM -m pip install --upgrade hererocks

    return 0
}

function install_nvim_config {
    set -e
    echo 'Checking config directory symlink...'

    if [ ! -d "$NVIM_PREF" ]; then
        echo "> Directory not found: $NVIM_PREF"
        exit 1
    fi

    if [ ! -L "$NVIM_ROOT" ]; then
        echo "> Creating symbolic link to configuration"
        ln -s "$NVIM_ROOT/" "$NVIM_PREFS"
    else
        echo "> Configuration link exists"
    fi

    return 0
}


function install_nvim_node {
    set -e
    echo 'Checking Node environment...'

    if [ ! `command -v nvm &> /dev/null` ]; then
        if [ ! -d "$HOME/.nvm" ]; then
            NVM_VERSION="0.39.7"
            NVM_INSTALL="https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh"
            curl -o- "$NVM_INSTALL" | bash
        fi
        echo "> Activating NVM"
        if [ ! -f "$HOME/.nvm/nvm.sh" ]; then
            echo "> NVM not found, see: https://github.com/nvm-sh/nvm"
            exit 1
        fi
        source "$HOME/.nvm/nvm.sh"
    else
        echo "> NVM exists is activate"
    fi

    nvm install node
    nvm alias nvim node
    nvm use nvim
    npm install -g neovim

    if [ ! -L "$HOME/.local/bin/nvim-node" ]; then
        echo "> Creating symbolic link to node"
        ln -s "$(which node)" "$HOME/.local/bin/nvim-node"
    fi
    if [ ! -L "$HOME/.local/bin/nvim-npm" ]; then
        echo "> Creating symbolic link to npm"
        ln -s "$(which npm)" "$HOME/.local/bin/nvim-npm"
    fi

    return 0
}


function install_nvim_lua {
    set -e
    echo 'Installing Lua environment...'

    # Assert that PYTHON_NVIM is set
    if [ -z "$PYTHON_NVIM" ]; then
        echo "> Python environment not found"
        return 1
    fi

    LAZYROCKS_PATH="$HOME/.local/share/nvim/lazy-rocks"
    HEREROCKS_PATH="$LAZYROCKS_PATH/hererocks"
    LUAROCKS="$HEREROCKS_PATH/bin/luarocks"
    LUA="$HEREROCKS_PATH/bin/lua"

    if [ ! -d "$HEREROCKS_PATH" ]; then
        echo "> Creating Lua environment"
        mkdir -p "$LAZYROCKS_PATH"
    else
        echo "> Lua environment exists, version $($LUA -v) (luarocks $($LUAROCKS --version))"
    fi

    $PYTHON_NVIM -m hererocks "$HEREROCKS_PATH" -r latest --lua=5.1 --patch
    source "$HEREROCKS_PATH/bin/activate"
    $LUAROCKS install magick

    return 0
}

NVIM_ROOT="$HOME/.config/nvim"
NVIM_PREF="$HOME/preferences/config/nvim"

install_nvim_binary
install_nvim_venv
install_nvim_config
install_nvim_node
install_nvim_lua

echo 'Done!'

