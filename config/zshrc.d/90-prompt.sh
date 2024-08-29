# Check interactive session
if [[ $- != *i* ]] ; then
  return 0
fi

# Check starship install
export STARSHIP_CONFIG=~/preferences/config/starship.toml
if `command -v starship &> /dev/null`; then
    eval "$(starship init zsh)"
    return 0
fi
