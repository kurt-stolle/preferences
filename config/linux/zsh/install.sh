#!/bin/bash
set -eu pipefail

DIR=`dirname $(readlink -f $0)`
ZSHRC="$HOME/.zshrc"

# ZSH check
ZSH=/bin/zsh
if ! command -v $ZSH >/dev/null 2>&1 ; then
    echo "Zsh is not installed @ $ZSH"
    exit 1
fi

# Oh my ZSH
OH_MY_ZSH="$HOME/.oh-my-zsh"
if ! [ -d "$OH_MY_ZSH" ]; then
    echo "Installing Oh My ZSH (see: https://ohmyz.sh/)"
    sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
else
    echo "Oh my ZSH already installed"
fi

# Preferences
LINE_BEGIN="## BEGIN PREFERENCES @ $DIR"
LINE_DONE="## END PREFERENCES"

if grep -q -F "$LINE_BEGIN" "$ZSHRC"; then
    echo "Zsh preferences already installed. Manually remove from your configuration ($ZSHRC) to update."
else
    echo "Installing Zsh preferences."
    echo $LINE_BEGIN >> $ZSHRC
    echo "export KURT_PREFERENCES_ZSH=\"$DIR\"" >> $ZSHRC
    echo "source $DIR/config" >> $ZSHRC
    echo $LINE_DONE >> $ZSHRC
fi

# Theme
echo "Installing Zsh theme"
ZSH_THEME="$OH_MY_ZSH/themes/kurt.zsh-theme"
rm -f $ZSH_THEME
ln -s "$DIR/kurt.zsh-theme" $ZSH_THEME
