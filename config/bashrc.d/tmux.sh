# Create command 'tmux-session' that creates or attaches to a TMux session with the name equal to the shell PID
# When the shell exits, trap is used to close the TMux session too
alias tmux-trap='tmux new-session -As $$'
__kill_tmux_trap() { tmux kill-session -t $$ 2>/dev/null; }
trap __kill_tmux_trap EXIT

# Create command 'tmux-default' that creates or attaches to a default TMux session
alias tmux-default='tmux new-session -As tmux-$(id -u)'
