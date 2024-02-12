#!/bin/bash
set -eu pipefail

DIR=`dirname $(readlink -f $0)`
DIR="$DIR/../.."

echo "Starting preferences installation..."
echo "Preferences @ $DIR"

## Check environment
# Are we root?
if ! [ "$EUID" -ne 0 ]; then
    echo "Preferences should not be installed as root/sudo"
    exit
fi

# Is wget installed?
if ! command -v wget >/dev/null 2>&1 ; then
    echo "'wget' command not installed."
    exit
fi

## Install modules
$DIR/config/linux/tmux/install.sh
$DIR/config/linux/vim/install.sh
$DIR/config/linux/zsh/install.sh

## Completed
echo "Done! All available preferences were installed."
