#!/bin/bash
set -e


NVIM_ROOT="$HOME/.config/nvim"

echo "Checking config root path @ $NVIM_ROOT"
if [ ! -d "$NVIM_ROOT" ]; then
	echo "> creating config path."
	mkdir -p "$NVIM_ROOT"
else
	echo "> nvim config path exists."
fi
NVIM_CONFIG="$NVIM_ROOT/init.lua"

echo 'Checking `init.lua` file...'

if [ ! -L "$NVIM_CONFIG" ]; then
	echo "> Creating symbolic link to configuration"
	ln -s "$HOME/preferences/config/nvim/init.lua" "$NVIM_CONFIG"
else
	echo "> Configuration link exists"
fi

echo 'Done!'
