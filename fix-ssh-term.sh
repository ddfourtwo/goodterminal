#!/bin/bash

echo "=== SSH Terminal Configuration Fix ==="
echo

echo "Current TERM: $TERM"
echo "This should be 'xterm-256color' or similar, not 'dumb'"
echo

echo "Setting proper TERM environment..."
export TERM=xterm-256color

echo "New TERM: $TERM"
echo

echo "Testing terminal capability with proper TERM..."
echo "1. Bell test:"
printf '\a'
sleep 1

echo "2. Window title test:"
printf '\033]0;TERM_FIXED_TEST\033\\'
echo "   Check if window title changed to 'TERM_FIXED_TEST'"
sleep 2

echo "3. OSC 52 test with proper TERM:"
test_content="TERM_FIXED_OSC52_$(date +%s)"
encoded=$(printf '%s' "$test_content" | base64 | tr -d '\n')

echo "   Sending: $test_content"
printf '\033]52;c;%s\033\\' "$encoded"

echo
echo "Check clipboard for: $test_content"
echo
echo "If this works, add to your SSH configuration:"
echo "  ~/.ssh/config:"
echo "  Host xps"
echo "    RequestTTY yes"
echo "    SendEnv TERM"
echo
echo "Or add to remote ~/.bashrc or ~/.zshrc:"
echo "  export TERM=xterm-256color"