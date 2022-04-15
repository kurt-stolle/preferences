#!/bin/bash
set -eu pipefail

if ! [ "$EUID" -ne 0 ]; then
    echo "Run script root/sudo"
    exit
fi

echo "Installing Docker via package manager."

# Uninstall
apt-get remove docker docker-engine docker.io containerd runc

# Add key
apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install
apt-get update -q
apt-get install -qy docker-ce docker-ce-cli containerd.io