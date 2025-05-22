#!/bin/bash

echo "=== Environment Variables ==="
echo "SSH_CLIENT: [$SSH_CLIENT]"
echo "SSH_TTY: [$SSH_TTY]"
echo "SSH_CONNECTION: [$SSH_CONNECTION]"
echo "MOSH_KEY: [${MOSH_KEY:0:10}...]"  # Only show first 10 chars for security
echo "TERM: [$TERM]"
echo "TMUX: [$TMUX]"

echo -e "\n=== Process Information ==="
echo "PPID: $PPID"
echo "Current process tree:"
pstree -ps $$ 2>/dev/null || ps -f -p $PPID 2>/dev/null

echo -e "\n=== Testing mosh detection ==="
echo "MOSH_KEY present: $([ -n "$MOSH_KEY" ] && echo "YES" || echo "NO")"
echo "Process check result:"
ps -p $PPID 2>/dev/null | grep mosh-server || echo "  No mosh-server found in parent"

is_mosh_session() {
    # Check for MOSH_KEY environment variable
    [ -n "$MOSH_KEY" ] && return 0
    
    # Check if any ancestor process is mosh-server
    local pid=$$
    while [ $pid -ne 1 ]; do
        if ps -p $pid -o comm= 2>/dev/null | grep -q mosh-server; then
            return 0
        fi
        pid=$(ps -p $pid -o ppid= 2>/dev/null | tr -d ' ')
        [ -z "$pid" ] || [ "$pid" = "1" ] && break
    done
    
    # Check if mosh-server is in process tree (fallback)
    pstree -p $$ 2>/dev/null | grep -q mosh-server && return 0
    
    return 1
}

if is_mosh_session; then
    echo "✅ Mosh session detected"
else
    echo "❌ Mosh session NOT detected"
fi

echo -e "\n=== Testing SSH detection ==="
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
    echo "✅ SSH session detected"
else
    echo "❌ SSH session NOT detected"
fi

echo -e "\n=== Testing tmux-yank copy command ==="
echo "Copy command setting: $(tmux show-option -gv @override_copy_command 2>/dev/null)"
echo "Current copy script path: $HOME/.tmux/ssh-copy.sh"
echo "Script exists: $([ -f "$HOME/.tmux/ssh-copy.sh" ] && echo "YES" || echo "NO")"