#!/bin/bash
# Test OSC 52 clipboard support

echo "Testing OSC 52 clipboard support..."
echo "This should copy 'Hello from remote!' to your clipboard"

# Simple OSC 52 test
printf '\033]52;c;%s\a' $(echo -n "Hello from remote!" | base64)

echo "Check your Mac clipboard now (Cmd+V somewhere)"