#!/bin/bash
set -e

# Directory where the Tmux configuration lives
CONFIG_DIR="$HOME/.config/tmux"
if [ ! -d "$CONFIG_DIR" ]; then
  mkdir -p $CONFIG_DIR
fi

# Path to the Tmux configuration file
TMUX_CONFIG="$CONFIG_DIR/tmux.conf"

# Path to our own Tmux configurations, which we source from $TMUX_CONFIG
MY_CONFIG="$HOME/preferences/config/tmux/tmux.conf"

# Check whether the Tmux configuration file sources our configurations
echo "Checking for our own configurations ..."
if [ ! -f "$TMUX_CONFIG" ]; then
    echo "> Creating $TMUX_CONFIG..."
    touch $TMUX_CONFIG
else
    echo "> Found $TMUX_CONFIG."
fi
if ! grep -q "$MY_CONFIG" "$TMUX_CONFIG"; then
    echo "> Sourcing our own configurations @ $MY_CONFIG."
    echo "source-file $MY_CONFIG" >> $TMUX_CONFIG
else
    echo "> Our own configurations are already sourced."
fi

# Check TPM install
echo "Checking for TPM install..."
TPM_GIT_REPO="https://github.com/tmux-plugins/tpm.git"
TPM_INSTALL_DIR="$CONFIG_DIR/plugins/tpm"
if [ ! -d "$TPM_INSTALL_DIR" ]; then
    echo "> Installation not found @ $TPM_INSTALL_DIR"
    echo "> Installing TPM..."
    git clone "$TPM_GIT_REPO" "$TPM_INSTALL_DIR"
else
    echo "> TPM already installed."
fi

# Check whether a symlink exists from $HOME/.tmux to $CONFIG_DIR
CONFIG_SYMLINK="$HOME/.tmux"
echo "Checking for symlink $CONFIG_SYMLINK..."
if [ ! -L "$CONFIG_SYMLINK" ]; then
    echo "> Symlink not found @ $CONFIG_SYMLINK"
    echo "> Creating symlink..."
    ln -s $CONFIG_DIR $CONFIG_SYMLINK
else
    echo "> Symlink already exists."
fi

# Done!
echo "Tmux preferences installed! Remember to install plugins: <leader> I"
