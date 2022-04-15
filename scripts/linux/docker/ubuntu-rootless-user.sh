#!/bin/bash
set -eu pipefail

if ! [ "$EUID" -ne 0 ]; then
    echo "Run script without root/sudo"
    exit
fi

echo "Setting-up Rootless Docker for current user $USER"

dockerd-rootless-setuptool.sh install

for RCFILE in "$HOME/.zshrc" "$HOME/.bashrc"
do
	if [ -d $RCFILE ]; then
        echo "Adding to $RCFILE"
        echo 'export PATH=/usr/bin:$PATH' >> $RCFILE
        echo 'export DOCKER_HOST=unix:///run/user/$USER/docker.sock' >> $RCFILE
    else
        echo "Skipping install to $RCFILE"
    fi
done

echo "Rootless docker setup completed"
