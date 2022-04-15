#!/bin/bash
set -eu pipefail

if ! [ "$EUID" -ne 0 ]; then
    echo "Run script root/sudo"
    exit
fi

echo "Setting up rootless docker"

# Install
echo "Installing extras"
apt-get install -y docker-ce-rootless-extras

# Disable system-wide
echo "Disabling system-wide docker"
systemctl disable --now docker.service docker.socket

