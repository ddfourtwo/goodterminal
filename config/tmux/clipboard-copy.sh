#!/bin/bash

# Universal clipboard copy script for tmux
# Automatically detects and uses the best available clipboard utility

# Read input
input=$(cat)

# If we're in an SSH session, try OSC 52 first to copy to local clipboard
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
    # Encode content in base64 for OSC 52
    encoded=$(printf '%s' "$input" | base64 | tr -d '\n')
    
    # Send OSC 52 escape sequence - use proper tmux passthrough
    if [ -n "$TMUX" ]; then
        # Inside tmux, use passthrough sequence
        printf '\033Ptmux;\033\033]52;c;%s\033\033\\\033\\' "$encoded"
    else
        # Direct to terminal
        printf '\033]52;c;%s\033\\' "$encoded"
    fi
    
    # Also copy to remote clipboard if available
    if command -v xsel &> /dev/null; then
        printf '%s' "$input" | xsel --clipboard --input
    elif command -v xclip &> /dev/null; then
        printf '%s' "$input" | xclip -selection clipboard
    elif command -v wl-copy &> /dev/null; then
        printf '%s' "$input" | wl-copy
    fi
else
    # Local session - use normal clipboard utilities
    if command -v pbcopy &> /dev/null; then
        # macOS
        printf '%s' "$input" | pbcopy
    elif command -v xsel &> /dev/null; then
        # Linux X11 with xsel
        printf '%s' "$input" | xsel --clipboard --input
    elif command -v xclip &> /dev/null; then
        # Linux X11 with xclip
        printf '%s' "$input" | xclip -selection clipboard
    elif command -v wl-copy &> /dev/null; then
        # Wayland
        printf '%s' "$input" | wl-copy
    fi
fi