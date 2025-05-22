#!/bin/bash

# Test script for clipboard integration
# This script tests if clipboard utilities can properly copy/paste clipboard content

set -e

echo "Testing clipboard integration..."

# Detect platform and set clipboard commands
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CLIP_COPY="pbcopy"
    CLIP_PASTE="pbpaste"
    PLATFORM="macOS (pbcopy/pbpaste)"
elif command -v xsel &> /dev/null; then
    # Linux with xsel
    CLIP_COPY="xsel --clipboard --input"
    CLIP_PASTE="xsel --clipboard --output"
    PLATFORM="Linux (xsel)"
elif command -v xclip &> /dev/null; then
    # Linux with xclip
    CLIP_COPY="xclip -selection clipboard"
    CLIP_PASTE="xclip -selection clipboard -o"
    PLATFORM="Linux (xclip)"
elif command -v wl-copy &> /dev/null; then
    # Wayland
    CLIP_COPY="wl-copy"
    CLIP_PASTE="wl-paste"
    PLATFORM="Wayland (wl-clipboard)"
else
    echo "❌ ERROR: No clipboard utility found!"
    echo ""
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "On macOS, pbcopy/pbpaste should be available by default."
    else
        echo "On Linux, please install a clipboard utility:"
        echo "  sudo apt install xsel xclip        # Debian/Ubuntu"
        echo "  sudo yum install xsel xclip        # RHEL/CentOS"
        echo "  sudo pacman -S xsel xclip          # Arch"
        echo "  sudo apt install wl-clipboard      # Wayland"
    fi
    exit 1
fi

echo "Platform: $PLATFORM"

# Test string
TEST_STRING="Hello from tmux clipboard! $(date)"

echo "Original string: $TEST_STRING"

# Copy to clipboard
echo "$TEST_STRING" | eval "$CLIP_COPY"

echo "String copied to clipboard using $PLATFORM"

# Read from clipboard
CLIPBOARD_CONTENT=$(eval "$CLIP_PASTE")

echo "String read from clipboard: $CLIPBOARD_CONTENT"

# Verify they match
if [ "$TEST_STRING" = "$CLIPBOARD_CONTENT" ]; then
    echo "✅ SUCCESS: Clipboard integration working correctly!"
    echo ""
    echo "Now test in tmux:"
    echo "1. Start tmux: tmux"
    echo "2. Enter copy mode: Ctrl+[ or prefix+["
    echo "3. Select text with mouse or v key"
    echo "4. Copy with y key"
    echo "5. Text should now be in your system clipboard"
    echo "6. You can paste with Cmd+V (macOS) or Ctrl+V (Linux) in other applications"
else
    echo "❌ FAILED: Clipboard integration not working"
    echo "Expected: $TEST_STRING"
    echo "Got: $CLIPBOARD_CONTENT"
    exit 1
fi