#!/bin/bash

# Download AppImage if Wezterm is not installed
function download_wezterm {
    if command -v wezterm &> /dev/null; then
        echo "Wezterm is already installed"
        return 1
    fi

    echo "Downloading Wezterm..."

    local WEZ_RELEASE="20240203-110809-5046fc22/WezTerm-20240203-110809-5046fc22-Ubuntu20.04.AppImage"
    local WEZ_BIN="$HOME/.local/bin/wezterm"

    echo "> Downloading {WEZ_RELEASE}"

    curl -sLo "${WEZ_BIN}" "https://github.com/wez/wezterm/releases/download/${WEZ_TARGET}"
    chmod +x "${WEZ_BIN}"

    echo "> Installed to ${WEZ_BIN}"

    return 0
}

function symlink_config {
    local WEZ_CONFIG="$HOME/.config/wezterm"
    local OUR_CONFIG="$HOME/preferences/config/wezterm"

    if [ -d "${WEZ_CONFIG}" ]; then
        echo "Wezterm config already exists"
        return 1
    fi

    echo "Symlinking Wezterm config..."

    ln -s "${OUR_CONFIG}" "${WEZ_CONFIG}"

    echo "> Symlinked ${OUR_CONFIG} to ${WEZ_CONFIG}"

    return 0
}

download_wezterm
symlink_config

echo "Done."

exit 0

