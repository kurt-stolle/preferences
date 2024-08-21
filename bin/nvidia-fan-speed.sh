#!/bin/bash

# If the script fails, first set the cool bits:
#     nvidia-xconfig -a --cool-bits=28 --allow-empty-initial-configuration

# Paths to the utilities we will need
NVIDIA_SMI='/usr/bin/nvidia-smi'
NVIDIA_SETTINGS='/usr/bin/nvidia-settings'

# Determine major driver version
VER=`awk '/NVIDIA/ {print $8}' /proc/driver/nvidia/version | cut -d . -f 1`

# Drivers from 285.x.y on allow persistence mode setting
if [ ${VER} -lt 285 ]; then
    echo "Error: Current driver version is ${VER}. Driver version must be greater than 285."; exit 1;
fi

# Read a numerical command line arg between 40 and 100
if [ "$1" -eq "$1" ] 2>/dev/null && [ "0$1" -ge "40" ]  && [ "0$1" -le "100" ]
then
    $NVIDIA_SMI -pm 1 # enable persistance mode
    speed=$1   # set speed

    echo "Setting fan to $speed%."

    # how many GPU's are in the system?
    NUMGPU="$(nvidia-smi -L | wc -l)"

    # loop through each GPU and individually set fan speed
    n=0
    while [  $n -lt  $NUMGPU ];
    do
        # start an x session, and call nvidia-settings to enable fan control and set speed
        xinit ${NVIDIA_SETTINGS} -a [gpu:${n}]/GPUFanControlState=1 -a [fan:${n}]/GPUTargetFanSpeed=$speed --  :0 -once
        let n=n+1
    done

    echo "Complete"; exit 0;

elif [ "x$1" = "xstop" ]
then
    $NVIDIA_SMI -pm 0 # disable persistance mode

    echo "Enabling default auto fan control."

    # how many GPU's are in the system?
    NUMGPU="$(nvidia-smi -L | wc -l)"

    # loop through each GPU and individually set fan speed
    n=0
    while [  $n -lt  $NUMGPU ];
    do
        # start an x session, and call nvidia-settings to enable fan control and set speed
        xinit ${NVIDIA_SETTINGS} -a [gpu:${n}]/GPUFanControlState=0 --  :0 -once
        let n=n+1
    done

    echo "Complete"; exit 0;

else
    echo "Error: Please pick a fan speed between 40 and 100, or stop."; exit 1;
fi
