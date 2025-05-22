#!/bin/bash

# Universal clipboard copy script for tmux
# Automatically detects and uses the best available clipboard utility

# Priority order: pbcopy (macOS) > xsel > xclip > wl-copy
if command -v pbcopy &> /dev/null; then
    # macOS
    pbcopy
elif command -v xsel &> /dev/null; then
    # Linux X11 with xsel
    xsel --clipboard --input
elif command -v xclip &> /dev/null; then
    # Linux X11 with xclip
    xclip -selection clipboard
elif command -v wl-copy &> /dev/null; then
    # Wayland
    wl-copy
else
    # Fallback: just consume input without copying
    cat > /dev/null
fi