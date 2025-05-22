#!/bin/bash

# Setup script for GoodTerminal port forwarding system

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/goodterminal"

echo "Setting up GoodTerminal Port Forwarding..."

# Create config directory
mkdir -p "$CONFIG_DIR"

# Copy port forwarding script to scripts directory
if [[ ! -f "$HOME/.config/goodterminal/scripts/port-forward.sh" ]]; then
    mkdir -p "$HOME/.config/goodterminal/scripts"
    cp "$SCRIPT_DIR/port-forward.sh" "$HOME/.config/goodterminal/scripts/"
    chmod +x "$HOME/.config/goodterminal/scripts/port-forward.sh"
fi

# Copy tmux status script
if [[ ! -f "$HOME/.config/tmux/port-status.sh" ]]; then
    mkdir -p "$HOME/.config/tmux"
    cp "$SCRIPT_DIR/../config/tmux/port-status.sh" "$HOME/.config/tmux/"
    chmod +x "$HOME/.config/tmux/port-status.sh"
fi

# Create initial config file
if [[ ! -f "$CONFIG_DIR/port-forwards.conf" ]]; then
    cat > "$CONFIG_DIR/port-forwards.conf" << 'EOF'
# GoodTerminal Port Forwarding Configuration
# Format: LOCAL_PORT:REMOTE_HOST:REMOTE_PORT:DESCRIPTION
# Example: 3000:localhost:3000:React Development Server

# Common development ports (uncomment to enable):
# 3000:localhost:3000:React/Next.js Dev Server
# 5173:localhost:5173:Vite Dev Server
# 8080:localhost:8080:Generic Dev Server
# 4000:localhost:4000:Express/API Server

# Add your custom port forwards below:
EOF
fi

# Add alias to shell config if not present
SHELL_CONFIG=""
if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
fi

if [[ -n "$SHELL_CONFIG" ]]; then
    if ! grep -q "port-forward.sh" "$SHELL_CONFIG"; then
        echo "" >> "$SHELL_CONFIG"
        echo "# GoodTerminal Port Forwarding alias" >> "$SHELL_CONFIG"
        echo "alias pf='~/.config/goodterminal/scripts/port-forward.sh'" >> "$SHELL_CONFIG"
        echo "alias ports='~/.config/goodterminal/scripts/port-forward.sh status'" >> "$SHELL_CONFIG"
    fi
fi

echo "✅ Port forwarding system setup complete!"
echo ""
echo "Usage:"
echo "  pf auto     - Auto-detect and forward development servers"
echo "  pf status   - Show current port forwards"
echo "  pf add 3000 - Add custom port forward"
echo ""
echo "Tmux keybindings:"
echo "  prefix + P     - Auto-detect and forward ports"
echo "  prefix + Ctrl+p - Show port status"
echo "  prefix + Alt+p  - Stop all forwards"
echo ""
echo "The status bar will show active forwards: ⇄ 3000 8080"