#!/bin/bash

echo "=== SSH OSC 52 Comprehensive Test ==="
echo

# Check SSH forwarding capabilities
echo "1. SSH Environment Check:"
echo "   SSH_CLIENT: ${SSH_CLIENT:-not set}"
echo "   SSH_TTY: ${SSH_TTY:-not set}"
echo "   SSH_CONNECTION: ${SSH_CONNECTION:-not set}"
echo "   TERM: ${TERM:-not set}"
echo

# Test if terminal supports OSC sequences at all
echo "2. Testing terminal capability..."
echo "   Sending bell sequence (should make a sound/flash):"
printf '\a'
sleep 1
echo "   Did you hear/see a bell? If not, terminal might not process escape sequences"
echo

# Test basic OSC sequence (window title)
echo "3. Testing window title change (OSC 0)..."
printf '\033]0;OSC_TEST_WINDOW_TITLE\033\\'
echo "   Check if your terminal window title changed to 'OSC_TEST_WINDOW_TITLE'"
sleep 2
echo

# Test OSC 52 with different approaches
echo "4. Testing OSC 52 clipboard access..."

test_content="SSH_OSC52_TEST_$(date +%s)"
encoded=$(printf '%s' "$test_content" | base64 | tr -d '\n')

echo "   Test content: $test_content"
echo "   Base64 encoded: $encoded"
echo

# Method 1: Direct to stderr
echo "   Method 1: OSC 52 to stderr"
printf '\033]52;c;%s\033\\' "$encoded" >&2

echo "   Method 2: OSC 52 to stdout"
printf '\033]52;c;%s\033\\' "$encoded"

echo
echo "   Method 3: OSC 52 with explicit newline"
printf '\033]52;c;%s\033\\\n' "$encoded"

echo
echo "5. Check your local clipboard now - it should contain: $test_content"
echo
echo "If none of these worked, the issue could be:"
echo "   - SSH client not forwarding OSC sequences"
echo "   - SSH server blocking escape sequences"
echo "   - iTerm2 not recognizing the OSC 52 format"
echo "   - Terminal multiplexer interference"