#!/bin/bash
#
# Simple installation script to do a user install of tmux.
#

set -e

TMUX_VERSION='3.4'
PREFIX="$HOME/.local"

mkdir -p "$PREFIX"

echo "Installing tmux version ${TMUX_VERSION} to ${PREFIX}..."
TMP_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t '.tmp')
if [[ ! "$TMP_DIR" || ! -d "$TMP_DIR" ]]; then
    echo "Could not create temporary working directory!"
    exit 1
fi
function cleanup {
  rm -rf "$TMP_DIR"
  echo "Deleted temp working directory ${WORK_DIR}"
}
trap cleanup EXIT

# Go to working directory
cd "$TMP_DIR"

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"

# Check whether `ncurses` is installed, else install it from source
if ! command -v ncurses-config &> /dev/null; then
    echo "Installing ncurses from source..."
    wget "https://ftp.gnu.org/gnu/ncurses/ncurses-6.2.tar.gz" -O "ncurses.tar.gz"
    tar -xzf ncurses.tar.gz
    cd ncurses-*
    ./configure --prefix="$PREFIX" --with-shared --enable-widec --with-termlib --enable-pc-files --with-pkg-config-libdir="$PKG_CONFIG_PATH"
    make -j"$(nproc)" && make install
    cd "$TMP_DIR"
fi


# Check whether `libevent` is installed, else install it from source
if ! command -v libevent-config &> /dev/null; then
    echo "Installing libevent from source..."
    wget "https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz" -O "libevent.tar.gz"
    tar -xzf "libevent.tar.gz"
    cd libevent-*
    ./configure --prefix="$PREFIX" --enable-shared
    make -j"$(nproc)" && make install
    cd "$TMP_DIR"
fi

# Install `tmux` from source
echo "Installing tmux from source..."
wget "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz" -O "tmux.tar.gz"
tar -xzf tmux.tar.gz
cd "tmux-${TMUX_VERSION}"
./configure --prefix="$PREFIX" --enable-sixel
make -j"$(nproc)" && make install
