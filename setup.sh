#!/bin/bash

host="https://kurt-stolle.github.io/preferences"

# Tmux
echo "Installing Tmux preferences"
wget -O $HOME/.tmux.conf "$host/tmux/config.conf" -q --show-progress
tmux source-file $HOME/.tmux.conf

# Vim configuration by Amix
vimrtdir="$HOME/.vim-runtime"
if [ ! -d $vimrtdir ]
then
    echo "Installing Vim configuration: UltimateVim (See: https://github.com/amix/vimrc)"
    vimrctmp="$HOME/.kurt-stolle/preferences"
    mkdir -p "$vimrctmp"

    vimrtzip="$vimrctmp/vimrc-master.zip"
    wget -O "$vimrtzip" https://github.com/amix/vimrc/archive/refs/heads/master.zip -q --show-progress

    unzip -qn "$vimrtzip"

    mv vimrc-master $vimrtdir
    sh "$vimrtdir/install_awesome_vimrc.sh"

    rm -rf $vimrctmp

else
    echo "Vim configuration already installed under $HOME/.vim-runtime"
fi

# IDEA Vim emulation
echo "Installing Vim preferences for IntelliJ-based IDEs"
wget -O $HOME/.ideavimrc "$host/vim/ideavimrc" -q --show-progress

# Completed
echo "DONE"
