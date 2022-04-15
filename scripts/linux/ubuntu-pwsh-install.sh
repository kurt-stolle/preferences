#!/bin/bash
set -eu pipefail

UBUNTU_VERSION="20.04"

if [ "$EUID" -ne 0 ]; then
    echo "Installation requires root/sudo"
    exit
fi

echo "Installing PowerShell using package manager for Ubuntu $UBUNTU_VERSION."

# Install pre-requisite packages.
apt-get update -q && apt-get install -y wget apt-transport-https software-properties-common

# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/$UBUNTU_VERSION/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm -f package-microsoft-prod.deb

# Update the list of packages after we added packages.microsoft.com
apt-get update -q && apt-get install -y powershell