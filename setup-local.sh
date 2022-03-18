#!/bin/bash
set -euxo pipefail

dir=`dirname $(readlink -f $0)`
echo "Running linked installation @ $dir"

# Tmux
echo "Installing Tmux preferences"
rm -f "$HOME/.tmux.conf"
ln -s "$dir/tmux/config.conf" "$HOME/.tmux.conf"
tmux source-file $HOME/.tmux.conf

# Vim configuration by Amix
vimrtdir="$HOME/.vim_runtime"
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
ln -s "$dir/vim/ideavimrc" "$HOME/.ideavimrc"

# ZSH configuration
$dir/zsh/install.sh

# Completed
echo "DONE"
