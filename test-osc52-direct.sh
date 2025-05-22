#!/bin/bash

# Direct OSC 52 test without any layers

echo "=== Direct OSC 52 Test ==="
echo

# Test string
test_string="Direct OSC52 test $(date +%s)"
echo "Test string: $test_string"

# Method 1: Simple OSC 52 (what most terminals expect)
echo "Trying Method 1: Simple OSC 52..."
encoded=$(printf '%s' "$test_string" | base64 | tr -d '\n')
printf '\e]52;c;%s\e\\' "$encoded"
echo "Sent simple OSC 52 sequence"
echo "Check clipboard now. Press Enter to continue..."
read

# Method 2: OSC 52 with BEL terminator
echo "Trying Method 2: OSC 52 with BEL..."
encoded=$(printf '%s' "$test_string BEL" | base64 | tr -d '\n')
printf '\e]52;c;%s\a' "$encoded"
echo "Sent OSC 52 with BEL terminator"
echo "Check clipboard now. Press Enter to continue..."
read

# Method 3: Check if we're actually in tmux and use passthrough
if [ -n "$TMUX" ]; then
    echo "Trying Method 3: tmux passthrough..."
    encoded=$(printf '%s' "$test_string TMUX" | base64 | tr -d '\n')
    printf '\ePtmux;\e\e]52;c;%s\a\e\\' "$encoded"
    echo "Sent tmux passthrough sequence"
    echo "Check clipboard now. Press Enter to continue..."
    read
fi

# Method 4: Write directly to controlling terminal
echo "Trying Method 4: Direct to TTY..."
encoded=$(printf '%s' "$test_string TTY" | base64 | tr -d '\n')
printf '\e]52;c;%s\e\\' "$encoded" > "$(tty)"
echo "Sent directly to $(tty)"
echo "Check clipboard now."