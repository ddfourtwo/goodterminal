#!/bin/bash

# Debug tmux-yank configuration

echo "=== tmux-yank Debug ==="
echo

# Check if we're in SSH
echo "SSH Environment:"
echo "SSH_CLIENT: ${SSH_CLIENT:-not set}"
echo "SSH_TTY: ${SSH_TTY:-not set}"
echo "SSH_CONNECTION: ${SSH_CONNECTION:-not set}"
echo

# Check tmux environment
echo "Tmux Environment:"
echo "TMUX: ${TMUX:-not set}"
echo "TERM: ${TERM:-not set}"
echo

# Check tmux-yank plugin
echo "tmux-yank Plugin Status:"
if [ -d "$HOME/.tmux/plugins/tmux-yank" ]; then
    echo "✅ tmux-yank plugin installed at: $HOME/.tmux/plugins/tmux-yank"
    ls -la "$HOME/.tmux/plugins/tmux-yank/"
else
    echo "❌ tmux-yank plugin not found"
fi
echo

# Check clipboard utilities
echo "Clipboard Utilities:"
command -v xsel && echo "✅ xsel found" || echo "❌ xsel not found"
command -v xclip && echo "✅ xclip found" || echo "❌ xclip not found"
command -v wl-copy && echo "✅ wl-copy found" || echo "❌ wl-copy not found"
command -v pbcopy && echo "✅ pbcopy found" || echo "❌ pbcopy not found"
echo

# Check tmux key bindings
echo "Current tmux copy-mode bindings:"
if [ -n "$TMUX" ]; then
    tmux list-keys -T copy-mode-vi | grep -E "(y|copy)"
else
    echo "Not in tmux session - start tmux first"
fi
echo

# Test tmux-yank configuration
echo "tmux-yank Settings:"
if [ -n "$TMUX" ]; then
    echo "copy-command setting:"
    tmux show-options -g | grep -i copy || echo "No copy options set"
    echo
    echo "yank settings:"
    tmux show-options -g | grep -i yank || echo "No yank options set"
else
    echo "Start tmux to check settings"
fi