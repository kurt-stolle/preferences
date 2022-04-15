#!/bin/bash
set -eu pipefail

DIR=`dirname $(readlink -f $0)`
TMUX_CONF="$HOME/.tmux.conf"

echo "Installing Tmux preferences"
rm -f "$TMUX_CONF"
ln -s "$DIR/config.conf" "$TMUX_CONF"
if ! [ -z ${TMUX+x} ]; then
    echo "Reloading Tmux session configuration"
    tmux source-file "$TMUX_CONF"
else
    echo "Tmux session is not running; skipping reload"
fi

