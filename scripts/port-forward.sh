#!/bin/bash

# GoodTerminal Port Forwarding Manager
# Mimics VS Code Remote-SSH port forwarding for tmux sessions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$HOME/.config/goodterminal/port-forwards.conf"
PID_FILE="$HOME/.config/goodterminal/port-forwards.pid"
LOG_FILE="$HOME/.config/goodterminal/port-forwards.log"

# Common development ports to auto-detect
COMMON_PORTS=(3000 3001 4000 5000 5173 8000 8080 8888 9000 3333 4173 24678)

# Ensure config directory exists
mkdir -p "$(dirname "$CONFIG_FILE")"

# Initialize config file if it doesn't exist
if [[ ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" << 'EOF'
# GoodTerminal Port Forwarding Configuration
# Format: LOCAL_PORT:REMOTE_HOST:REMOTE_PORT:DESCRIPTION
# Example: 3000:localhost:3000:React Development Server

# Add your custom port forwards below:
EOF
fi

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_port() {
    local port=$1
    local host=${2:-localhost}
    
    if command -v nc >/dev/null 2>&1; then
        nc -z "$host" "$port" 2>/dev/null
    elif command -v netstat >/dev/null 2>&1; then
        netstat -ln 2>/dev/null | grep -q ":$port "
    elif [[ -e /proc/net/tcp ]]; then
        # Convert port to hex for /proc/net/tcp
        local hex_port=$(printf "%04X" "$port")
        grep -q ":$hex_port " /proc/net/tcp 2>/dev/null
    else
        # Fallback: try to connect
        timeout 1 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null
    fi
}

detect_running_servers() {
    local detected=()
    
    log "Scanning for running development servers..."
    
    for port in "${COMMON_PORTS[@]}"; do
        if check_port "$port"; then
            # Try to identify what's running on this port
            local description="Unknown Service"
            
            # Check for common development servers
            if command -v lsof >/dev/null 2>&1; then
                local process=$(lsof -ti tcp:$port 2>/dev/null | head -1)
                if [[ -n "$process" ]]; then
                    local cmd=$(ps -p "$process" -o comm= 2>/dev/null)
                    case "$cmd" in
                        *node*) description="Node.js Server" ;;
                        *python*) description="Python Server" ;;
                        *ruby*) description="Ruby Server" ;;
                        *php*) description="PHP Server" ;;
                        *nginx*) description="Nginx" ;;
                        *apache*) description="Apache" ;;
                        *) description="$cmd" ;;
                    esac
                fi
            fi
            
            detected+=("$port:localhost:$port:$description")
            log "  Found: $description on port $port"
        fi
    done
    
    printf '%s\n' "${detected[@]}"
}

start_forwarding() {
    local config_line="$1"
    IFS=':' read -r local_port remote_host remote_port description <<< "$config_line"
    
    # Check if SSH connection exists
    if [[ -z "$SSH_CLIENT" ]] && [[ -z "$SSH_TTY" ]]; then
        log "Warning: Not in SSH session, cannot create port forward for $local_port"
        return 1
    fi
    
    # Get SSH connection info
    local ssh_host=""
    if [[ -n "$SSH_CLIENT" ]]; then
        ssh_host=$(echo "$SSH_CLIENT" | awk '{print $1}')
    fi
    
    # Check if local port is already in use
    if check_port "$local_port" "$ssh_host" 2>/dev/null; then
        log "Port $local_port already forwarded"
        return 0
    fi
    
    # Create reverse SSH tunnel from remote to local machine
    log "Creating port forward: $local_port -> $remote_host:$remote_port ($description)"
    
    # Use SSH to create reverse tunnel
    ssh -f -N -R "$local_port:$remote_host:$remote_port" "$ssh_host" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        log "  Success: Port $local_port forwarded"
        echo "$local_port" >> "$PID_FILE"
        return 0
    else
        log "  Failed: Could not forward port $local_port"
        return 1
    fi
}

stop_forwarding() {
    if [[ -f "$PID_FILE" ]]; then
        log "Stopping all port forwards..."
        
        # Kill SSH processes for port forwarding
        pkill -f "ssh.*-R.*:.*:" 2>/dev/null
        
        rm -f "$PID_FILE"
        log "All port forwards stopped"
    else
        log "No active port forwards found"
    fi
}

status() {
    echo "GoodTerminal Port Forwarding Status"
    echo "=================================="
    
    if [[ -f "$PID_FILE" ]]; then
        echo "Active forwards:"
        while read -r port; do
            if [[ -n "$port" ]]; then
                echo "  Port $port"
            fi
        done < "$PID_FILE"
    else
        echo "No active port forwards"
    fi
    
    echo ""
    echo "Detected servers:"
    detect_running_servers | while IFS=':' read -r port host remote_port desc; do
        echo "  $port: $desc"
    done
}

auto_forward() {
    log "Starting auto-forwarding mode..."
    
    # Read custom configurations
    local custom_forwards=()
    while read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        custom_forwards+=("$line")
    done < "$CONFIG_FILE"
    
    # Detect running servers
    local detected_forwards=()
    readarray -t detected_forwards < <(detect_running_servers)
    
    # Combine custom and detected forwards
    local all_forwards=("${custom_forwards[@]}" "${detected_forwards[@]}")
    
    # Start forwarding for each
    for forward in "${all_forwards[@]}"; do
        [[ -n "$forward" ]] && start_forwarding "$forward"
    done
    
    log "Auto-forwarding setup complete"
}

show_help() {
    cat << 'EOF'
GoodTerminal Port Forwarding Manager

USAGE:
    port-forward.sh [COMMAND] [OPTIONS]

COMMANDS:
    auto        Auto-detect and forward common development ports
    start       Start forwarding based on config file
    stop        Stop all active port forwards
    status      Show status of port forwards and detected servers
    detect      Scan for running development servers
    add PORT    Add a custom port forward to config
    edit        Edit the configuration file
    help        Show this help message

EXAMPLES:
    # Auto-detect and forward all development servers
    port-forward.sh auto
    
    # Add a custom port forward
    port-forward.sh add 3000
    
    # Check what's currently running
    port-forward.sh status

TMUX INTEGRATION:
    Add to your tmux.conf:
    bind P run-shell "~/.config/goodterminal/port-forward.sh auto"

CONFIG FILE:
    ~/.config/goodterminal/port-forwards.conf
    
    Format: LOCAL_PORT:REMOTE_HOST:REMOTE_PORT:DESCRIPTION
    Example: 3000:localhost:3000:React Dev Server
EOF
}

add_forward() {
    local port="$1"
    if [[ -z "$port" ]]; then
        read -p "Enter local port: " port
    fi
    
    if [[ ! "$port" =~ ^[0-9]+$ ]]; then
        log "Error: Invalid port number"
        return 1
    fi
    
    read -p "Enter remote host [localhost]: " remote_host
    remote_host=${remote_host:-localhost}
    
    read -p "Enter remote port [$port]: " remote_port
    remote_port=${remote_port:-$port}
    
    read -p "Enter description: " description
    description=${description:-"Custom Forward"}
    
    echo "$port:$remote_host:$remote_port:$description" >> "$CONFIG_FILE"
    log "Added port forward: $port -> $remote_host:$remote_port"
}

# Main command handling
case "${1:-auto}" in
    auto)
        auto_forward
        ;;
    start)
        auto_forward
        ;;
    stop)
        stop_forwarding
        ;;
    status)
        status
        ;;
    detect)
        detect_running_servers
        ;;
    add)
        add_forward "$2"
        ;;
    edit)
        "${EDITOR:-nano}" "$CONFIG_FILE"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use 'port-forward.sh help' for usage information"
        exit 1
        ;;
esac