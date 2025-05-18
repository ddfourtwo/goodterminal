#!/bin/bash
# Cleanup script for tmux sessions and server

# Kill all tmux sessions
if command -v tmux &> /dev/null; then
    echo "Killing all tmux sessions..."
    # Kill all sessions
    tmux kill-server 2>/dev/null || true
    echo "✓ All tmux sessions terminated"
else
    echo "tmux not found - skipping"
fi

echo ""
echo "You can now run: ./install.sh"
echo "And select option 5 (Purge and Reinstall)"