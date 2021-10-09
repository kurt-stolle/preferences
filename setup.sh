#!/bin/bash

# Setup TMux
wget -O $HOME/.tmux.conf https://kurt-stolle.github.io/preferences/tmux/config.conf
tmux source-file $HOME/.tmux.conf
