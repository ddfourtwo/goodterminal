#!/bin/bash

read_key() {
    echo "Press Enter to continue..."
    read -r
}

echo "=== Clipboard Debug Script ==="
echo "Testing OSC 52 clipboard functionality over SSH"
echo
read_key

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
echo "Check if this appeared in your local clipboard"
read_key

# Test 2: Check tmux-yank plugin status
echo "Test 2: tmux-yank plugin status..."
tmux show-options -g | grep yank
echo
read_key

# Test 3: Check our copy command setting
echo "Test 3: Current copy command setting..."
tmux show-options -g | grep override_copy_command
echo
read_key

# Test 4: Test our SSH copy script directly
echo "Test 4: Testing SSH copy script directly..."
if [ -f "$HOME/.tmux/ssh-copy.sh" ]; then
    echo "Script exists at $HOME/.tmux/ssh-copy.sh"
    echo "Script permissions:"
    ls -la "$HOME/.tmux/ssh-copy.sh"
    echo "Testing script with sample content..."
    echo "SSH script test $(date)" | "$HOME/.tmux/ssh-copy.sh"
    echo "Script test completed - check if this appeared in your local clipboard"
else
    echo "ERROR: SSH copy script not found at $HOME/.tmux/ssh-copy.sh"
fi
echo
read_key

# Test 5: Check tmux key bindings
echo "Test 5: Current tmux key bindings for copy mode..."
tmux list-keys -T copy-mode-vi | grep -E "(y|Enter)"
echo
read_key

# Test 6: Environment check
echo "Test 6: Environment variables..."
echo "SSH_CLIENT: ${SSH_CLIENT:-not set}"
echo "SSH_TTY: ${SSH_TTY:-not set}"
echo "SSH_CONNECTION: ${SSH_CONNECTION:-not set}"
echo "TMUX: ${TMUX:-not set}"
echo
read_key

echo "=== Debug complete ==="
echo "Now try copying this line manually in tmux with 'y' and see if it appears in your local clipboard"