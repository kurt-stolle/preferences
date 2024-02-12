#!/bin/bash

# System-specific RCs
if [ -d ~/.bashrc.d ]; then
        for rc in ~/.bashrc.d/*; do
                if [ -f "$rc" ]; then
                        . "$rc"
                fi
        done
fi

# Preference RCs
if [ -d ~/preferences/config/bashrc ]; then
        for rc in ~/preferences/config/bashrc/*; do
                if [ -f "$rc" ]; then
                        . "$rc"
                fi
        done
fi
unset rc

