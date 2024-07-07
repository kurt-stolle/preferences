#!/bin/bash
set -e

# Version check
NVIM_VERSION_TARGET="v0.10.0"
NVIM_URL="https://github.com/neovim/neovim/releases/download/$NVIM_VERSION_TARGET/nvim.appimage"
NVIM_URL="https://github.com/neovim/neovim-releases/releases/download/$NVIM_VERSION_TARGET/nvim.appimage"
NVIM_BIN="$HOME/.local/bin/nvim"
NVIM_APPIMAGE="$NVIM_BIN.appimage"

# Check if Neovim is installed, and if it's the correct version, else download it
if [ ! -f "$NVIM_BIN" ]; then
    echo 'Neovim not found, downloading...'
    wget "$NVIM_URL" -O "$NVIM_APPIMAGE"
else
    echo 'Neovim found, checking version...'
    NVIM_VERSION_CURRENT="$($NVIM_BIN --version | head -n 1 | cut -d ' ' -f 2)"
    if [ "$NVIM_VERSION_CURRENT" != "$NVIM_VERSION_TARGET" ]; then
        echo "> Incorrect version: $NVIM_VERSION_CURRENT"
        rm -rf "$NVIM_BIN"
        echo "> Downloading version: $NVIM_VERSION_TARGET"
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

# Root
NVIM_ROOT="$HOME/.config/nvim"
NVIM_PREF="$HOME/preferences/config/nvim"

# Config file
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

# Python virtualenv
echo 'Installing Python packages...'

mkdir -p "$HOME/.venvs"
VENV_PATH="$HOME/.venvs/nvim"
if [ ! -d "$VENV_PATH" ]; then
    echo "> Creating virtual environment"
    python3 -m venv --prompt NeoVIm --symlinks --upgrade "$VENV_PATH"
else
    echo "> Virtual environment exists"
fi

PYTHON="$VENV_PATH/bin/python"
$PYTHON -m pip install --upgrade pip
$PYTHON -m pip install --upgrade -r "$HOME/preferences/config/nvim/requirements.txt"

# Node environment
# We use NVM to install Node, and then create an alias 'nvim' for the node version.
echo 'Checking Node environment...'

if [ ! `which nvm` ]; then
    if [ ! -d "$HOME/.nvm" ]; then
        NVM_INSTALL="wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh"
        echo "> Installing NVM"
        curl -o- "$NVM_INSTALL" | bash
    fi
    echo "> Activating NVM"
    source "$HOME/.nvm/nvm.sh"
else
    echo "> NVM exists is activate"
fi

nvm install node
nvm alias nvim node
nvm use nvim
npm install -g neovim

ln -s "`which node`" "$HOME/.local/bin/nvim-node"
ln -s "`which npm`" "$HOME/.local/bin/nvim-npm"

# Lua environment
echo 'Installing Lua environment...'

LAZYROCKS_PATH="$HOME/.local/share/nvim/lazy-rocks"
HEREROCKS_PATH="$LAZYROCKS_PATH/hererocks"

if [ ! -d "$HEREROCKS_PATH" ]; then
    echo "> Creating Lua environment"
    mkdir -p "$LAZYROCKS_PATH"
    $PYTHON -m hererocks "$HEREROCKS_PATH" -r latest --lua=5.1 --patch
else
    echo "> Lua environment exists"
fi

source "$HEREROCKS_PATH/bin/activate"
luarocks install magick

echo 'Done!'
