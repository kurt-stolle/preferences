#!/usr/bin/env bash
set -e

# Directory where the Zellij configuration lives
CONFIG_DIR="$HOME/.config/zellij"
if [ ! -d "$CONFIG_DIR" ]; then
  mkdir -p $CONFIG_DIR
fi

# Path to the Zellij configuration file
TGT_CONFIG="$CONFIG_DIR/config.kdl"
SRC_CONFIG="$HOME/preferences/config/zellij/config.kdl"

# Check whether the Zellij configuration file sources our configurations
echo "Checking for our own configurations ..."
if [ ! -f "$TGT_CONFIG" ]; then
    echo "> Creating $TGT_CONFIG..."
    ln -s $SRC_CONFIG $TGT_CONFIG
else
    echo "> Found $TGT_CONFIG."
fi

# Done!
echo "Zellij preferences installed!"
