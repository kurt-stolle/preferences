#!/bin/bash
# This script shows the current session type, either X11 or Wayland.
#
# Usage: show-session-type.sh
#

loginctl show-session `loginctl|grep $USER|awk '{print $1}'` -p Type
