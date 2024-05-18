#!/bin/bash
#
# Simple installation script to do a user install of tmux.
#

set -e

TMUX_VERSION='3.4'
PREFIX="$HOME/.local"

mkdir -p "$PREFIX"

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

cd "$TMP_DIR"
wget "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz" -O "tmux.tar.gz"
tar -xzf tmux.tar.gz
cd "tmux-${TMUX_VERSION}"
./configure --prefix="$PREFIX" --enable-sixel
make -j"$(nproc)" && make install
