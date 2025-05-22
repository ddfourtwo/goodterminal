#!/bin/bash

# SSH-aware copy script for tmux-yank
# Uses OSC 52 for SSH sessions, local clipboard otherwise

input=$(cat)

# Check if we're in SSH
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
    # SSH session - use OSC 52
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