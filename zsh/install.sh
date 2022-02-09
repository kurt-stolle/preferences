#!/bin/sh
set -e


dir=`dirname $(readlink -f $0)`
zshrc="$HOME/.zshrc"

echo "Installing ZSH preferences into $zshrc using root directory $dir"

echo "# Install personal preferences @ github.com/kurt-stolle/preferences" >> "$zshrc"
echo "export KURT_PREFERENCES_ZSH=\"$dir\"" >> "$zshrc"
echo "source $dir/config" >> "$zshrc"

ln -s "$dir/kurt.zsh-theme" "$HOME/.oh-my-zsh/themes/kurt.zsh-theme"
