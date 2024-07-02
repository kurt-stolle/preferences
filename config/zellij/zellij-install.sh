#!/usr/bin/env bash
set -e

# Directory where the Zellij configuration lives
CONFIG_DIR="$HOME/.config/zellij"
if [ ! -d "$CONFIG_DIR" ]; then
  mkdir -p $CONFIG_DIR
fi

# Path to the Zellij configuration file
TGT="$CONFIG_DIR/config.kdl"
SRC="$HOME/preferences/config/zellij/config.kdl"
echo "Checking for our own configurations ..."
if [ ! -f "$TGT" ]; then
    echo "> Creating $TGT..."
    ln -s $SRC $TGT
else
    echo "> Found $TGT."
fi

# Path to the Zellij layouts directories
TGT="$CONFIG_DIR/layouts"
SRC="$HOME/preferences/config/zellij/layouts"
echo "Checking for our own configurations ..."
if [ ! -f "$TGT" ]; then
    echo "> Creating $TGT..."
    ln -s $SRC $TGT
else
    echo "> Found $TGT."
fi

# Path to the Zellij themes directories
TGT="$CONFIG_DIR/themes"
SRC="$HOME/preferences/config/zellij/themes"
echo "Checking for our own configurations ..."
if [ ! -f "$TGT" ]; then
    echo "> Creating $TGT..."
    ln -s $SRC $TGT
else
    echo "> Found $TGT."
fi


# Done!
echo "Zellij preferences installed!"
