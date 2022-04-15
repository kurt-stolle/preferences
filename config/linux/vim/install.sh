#!/bin/bash
set -eu pipefail

DIR=`dirname $(readlink -f $0)`

# Check whether `unzip` is installed
UNZIP="unzip -qn"
if ! command -v $UNZIP >/dev/null 2>&1 ; then
    echo "'unzip' command not installed."
    exit 1
fi


# Use a default Vim configuration by Amix
VIM_RUNTIME="$HOME/.vim_runtime"
if ! [ -d $VIM_RUNTIME ]; then
    echo "Installing Vim configuration: UltimateVim (See: https://github.com/amix/vimrc)"

    TEMP=$(mktemp -d)
    TEMP_ZIP="$TEMP/vimrc-master.zip"

    wget -O "$TEMP_ZIP" https://github.com/amix/vimrc/archive/refs/heads/master.zip -q --show-progress
    $UNZIP "$TEMP_ZIP"

    mv vimrc-master $VIM_RUNTIME
    sh "$VIM_RUNTIME/install_awesome_vimrc.sh"

    rm -rf "$TEMP"
else
    echo "Vim configuration already installed under $HOME/.vim-runtime"
fi

# IDEA Vim emulation
IDEAVIMRC="$HOME/.ideavimrc"

echo "Installing Vim preferences for IntelliJ-based IDEs"
rm -f "$IDEAVIMRC"
ln -s "$DIR/vim/ideavimrc" "$IDEAVIMRC"

# VIM preferences
VIMRC="$HOME/.vimrc"
SOURCE_PREFS="source $DIR/config.vim"
if grep -q -F "$SOURCE_PREFS" "$VIMRC"; then
    echo "VIM preferences already installed."
else
    echo "Installing VIM preferences."
    echo "$SOURCE_PREFS" >> "$VIMRC"
fi
