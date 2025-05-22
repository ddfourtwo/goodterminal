#!/bin/bash

# Remote-aware copy script for tmux-yank
# Uses OSC 52 for SSH/mosh sessions, local clipboard otherwise

input=$(cat)

# Check if we're in mosh or SSH (check mosh first since it may have SSH vars too)
# For mosh detection, check multiple indicators
is_mosh_session() {
    # Check for MOSH_KEY environment variable
    [ -n "$MOSH_KEY" ] && return 0
    
    # Check if any ancestor process is mosh-server
    local pid=$$
    while [ $pid -ne 1 ]; do
        if ps -p $pid -o comm= 2>/dev/null | grep -q mosh-server; then
            return 0
        fi
        pid=$(ps -p $pid -o ppid= 2>/dev/null | tr -d ' ')
        [ -z "$pid" ] || [ "$pid" = "1" ] && break
    done
    
    # Check if mosh-server is in process tree (fallback)
    pstree -p $$ 2>/dev/null | grep -q mosh-server && return 0
    
    return 1
}

# Check mosh first, then SSH
if is_mosh_session || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
    # Remote session (SSH or mosh) - use OSC 52
    encoded=$(printf '%s' "$input" | base64 | tr -d '\n')
    
    if [ -n "$TMUX" ]; then
        # In tmux, use passthrough
        printf '\033Ptmux;\033\033]52;c;%s\033\033\\\033\\' "$encoded"
    else
        # Direct to terminal
        printf '\033]52;c;%s\033\\' "$encoded"
    fi
else
    # Local session - use system clipboard
    if command -v pbcopy &> /dev/null; then
        printf '%s' "$input" | pbcopy
    elif command -v xclip &> /dev/null; then
        printf '%s' "$input" | xclip -selection clipboard
    elif command -v xsel &> /dev/null; then
        printf '%s' "$input" | xsel --clipboard --input
    elif command -v wl-copy &> /dev/null; then
        printf '%s' "$input" | wl-copy
    fi
fi