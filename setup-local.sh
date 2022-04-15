#!/bin/bash
set -euxo pipefail

DIR=`dirname $(readlink -f $0)`
echo "Running linked installation @ $DIR"

# Tmux
echo "Installing Tmux preferences"
rm -f "$HOME/.tmux.conf"
ln -s "$dir/tmux/config.conf" "$HOME/.tmux.conf"
if [ -n $TMUX ] && tmux source-file $HOME/.tmux.conf

# VIM configuration
$DIR/vim/install.sh

# ZSH configuration
$DIR/zsh/install.sh

# Completed
echo "DONE"
