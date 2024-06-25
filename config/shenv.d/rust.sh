# Check if cargo is installed
if ! [ -d "$HOME/.cargo" ]; then
    return
fi

# Check whether cargo is in the PATH
if ! [[ "$PATH" =~ "$HOME/.cargo/bin" ]]
then
    PATH="$HOME/.cargo/bin:$PATH"
fi
export PATH

# Source cargo environment
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi
