#!/bin/bash

# Debug script to test clipboard integration

echo "=== Clipboard Debug Script ==="
echo

# Check SSH environment
echo "SSH Environment:"
echo "SSH_CLIENT: $SSH_CLIENT"
echo "SSH_TTY: $SSH_TTY" 
echo "SSH_CONNECTION: $SSH_CONNECTION"
echo

# Test if we can detect SSH
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
    echo "✅ SSH session detected"
else
    echo "❌ No SSH session detected"
fi
echo

# Test clipboard utilities
echo "Available clipboard utilities:"
command -v pbcopy && echo "✅ pbcopy (macOS)"
command -v xsel && echo "✅ xsel (Linux X11)"
command -v xclip && echo "✅ xclip (Linux X11)"
command -v wl-copy && echo "✅ wl-copy (Wayland)"
echo

# Test OSC 52 directly
echo "Testing OSC 52 escape sequence..."
test_string="Hello OSC52 test $(date)"
encoded=$(printf '%s' "$test_string" | base64 | tr -d '\n')
echo "Original: $test_string"
echo "Base64: $encoded"

# Send OSC 52 sequence
printf '\033]52;c;%s\033\\' "$encoded" > /dev/tty
echo "OSC 52 sequence sent to terminal"
echo

echo "Check your local clipboard now - it should contain: $test_string"
echo "Press Enter when you've checked..."
read