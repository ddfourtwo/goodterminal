#!/bin/bash

echo "=== Clipboard Debug Script ==="
echo "Testing OSC 52 clipboard functionality over SSH"
echo

# Test 1: Direct OSC 52 (should work)
echo "Test 1: Direct OSC 52 copy..."
test_content="Direct OSC 52 test $(date)"
encoded=$(printf '%s' "$test_content" | base64 | tr -d '\n')
if [ -n "$TMUX" ]; then
    printf '\033Ptmux;\033\033]52;c;%s\033\033\\\033\\' "$encoded"
else
    printf '\033]52;c;%s\033\\' "$encoded"
fi
echo "Sent to clipboard: $test_content"
echo

# Test 2: Check tmux-yank plugin status
echo "Test 2: tmux-yank plugin status..."
tmux show-options -g | grep yank
echo

# Test 3: Check our copy command setting
echo "Test 3: Current copy command setting..."
tmux show-options -g | grep override_copy_command
echo

# Test 4: Test our SSH copy script directly
echo "Test 4: Testing SSH copy script directly..."
if [ -f "$HOME/.tmux/ssh-copy.sh" ]; then
    echo "Script exists at $HOME/.tmux/ssh-copy.sh"
    echo "Script permissions:"
    ls -la "$HOME/.tmux/ssh-copy.sh"
    echo "Testing script with sample content..."
    echo "SSH script test $(date)" | "$HOME/.tmux/ssh-copy.sh"
    echo "Script test completed"
else
    echo "ERROR: SSH copy script not found at $HOME/.tmux/ssh-copy.sh"
fi
echo

# Test 5: Check tmux key bindings
echo "Test 5: Current tmux key bindings for copy mode..."
tmux list-keys -T copy-mode-vi | grep -E "(y|Enter)"
echo

# Test 6: Environment check
echo "Test 6: Environment variables..."
echo "SSH_CLIENT: ${SSH_CLIENT:-not set}"
echo "SSH_TTY: ${SSH_TTY:-not set}"
echo "SSH_CONNECTION: ${SSH_CONNECTION:-not set}"
echo "TMUX: ${TMUX:-not set}"
echo

echo "=== Debug complete ==="
echo "Try copying this line manually in tmux with 'y' and see if it appears in your local clipboard"