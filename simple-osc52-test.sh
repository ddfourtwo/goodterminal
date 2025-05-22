#!/bin/bash

echo "=== Simple OSC 52 Test ==="
echo

# First test - check if we're in SSH
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
    echo "✓ SSH session detected"
else
    echo "✗ Not in SSH session"
fi

if [ -n "$TMUX" ]; then
    echo "✓ Inside tmux"
else
    echo "✗ Not in tmux"
fi

echo

# Test OSC 52 with very simple content
echo "Testing OSC 52 with simple content..."
test_text="SIMPLE_TEST_$(date +%s)"
echo "Sending: $test_text"

# Base64 encode
encoded=$(printf '%s' "$test_text" | base64 | tr -d '\n')

# Send OSC 52 - test both with and without tmux
if [ -n "$TMUX" ]; then
    echo "Using tmux-wrapped OSC 52..."
    printf '\033Ptmux;\033\033]52;c;%s\033\033\\\033\\' "$encoded" >&2
else
    echo "Using direct OSC 52..."
    printf '\033]52;c;%s\033\\' "$encoded" >&2
fi

echo
echo "Test content sent: $test_text"
echo "Check your local clipboard - it should contain exactly: $test_text"
echo
echo "If this doesn't work, the issue is with:"
echo "1. Terminal OSC 52 support"
echo "2. SSH client/server OSC 52 forwarding"
echo "3. iTerm2 clipboard access settings"