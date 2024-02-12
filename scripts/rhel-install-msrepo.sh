#!/bin/bash
# Get version of RHEL
source /etc/os-release
if [ $(bc<<<"$VERSION_ID < 8") = 1 ]
then majorver=7
elif [ $(bc<<<"$VERSION_ID < 9") = 1 ]
then majorver=8
else majorver=9
fi

# Register the Microsoft RedHat repository
curl -sSL -O https://packages.microsoft.com/config/rhel/$majorver/packages-microsoft-prod.rpm

# Register the Microsoft repository keys
sudo rpm -i packages-microsoft-prod.rpm

# Delete the repository keys after installing
rm packages-microsoft-prod.rpm

# RHEL 7.x uses yum and RHEL 8+ uses dnf
if [ $(bc<<<"$majorver < 8") ]
then
    # Update package index files
    sudo yum update
    # Install PowerShell
    sudo yum install powershell -y
else
    # Update package index files
    sudo dnf update
    # Install PowerShell
    sudo dnf install powershell -y
fi
