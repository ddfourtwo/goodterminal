#!/bin/bash
# Remote clipboard helper for tmux + mosh + iTerm2

# Function to copy to clipboard using OSC 52
osc52_copy() {
    local text="$1"
    local encoded=$(echo -n "$text" | base64 | tr -d '\n')
    printf '\033]52;c;%s\a' "$encoded"
}

# Check if we're in a remote session
if [ -n "$SSH_CONNECTION" ] || [ -n "$MOSH_CONNECTION" ]; then
    # Read from stdin and copy using OSC 52
    input=$(cat)
    osc52_copy "$input"
else
    # Local session - use system clipboard
    if command -v pbcopy &> /dev/null; then
        pbcopy
    elif command -v xclip &> /dev/null; then
        xclip -selection clipboard
    elif command -v wl-copy &> /dev/null; then
        wl-copy
    fi
fi