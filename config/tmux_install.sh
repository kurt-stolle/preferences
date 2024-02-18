#!/bin/bash
#Installs the Tmux configuration and downloads any dependencies
#
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm --depth 0
ln -s ~/preferences/config/tmux/tmux.conf ~/.config/tmux/tmux.conf
