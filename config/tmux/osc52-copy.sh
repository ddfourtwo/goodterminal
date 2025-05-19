#!/usr/bin/env bash
# OSC 52 copy script for tmux

# Maximum length of OSC 52 escape sequence
MAX_LENGTH=74994

# Read input
input=$(cat)

# Base64 encode
encoded=$(printf '%s' "$input" | base64 | tr -d '\n')

# Check length
if [ ${#encoded} -gt $MAX_LENGTH ]; then
    encoded=${encoded:0:$MAX_LENGTH}
fi

# Use the appropriate escape sequence based on terminal
case "$TERM" in
    screen*|tmux*)
        # Inside tmux, we need to use the pass-through sequence
        printf '\033Ptmux;\033\033]52;c;%s\a\033\\' "$encoded"
        ;;
    *)
        # Regular OSC 52
        printf '\033]52;c;%s\a' "$encoded"
        ;;
esac