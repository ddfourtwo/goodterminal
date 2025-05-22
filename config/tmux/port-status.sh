#!/bin/bash

# Tmux status bar integration for port forwarding
# Shows active port forwards in tmux status line

PID_FILE="$HOME/.config/goodterminal/port-forwards.pid"
CONFIG_FILE="$HOME/.config/goodterminal/port-forwards.conf"

# Colors for tmux status bar
GREEN="#[fg=green]"
YELLOW="#[fg=yellow]"
RED="#[fg=red]"
BLUE="#[fg=blue]"
RESET="#[fg=default]"

get_port_status() {
    if [[ ! -f "$PID_FILE" ]]; then
        echo "${RED}No forwards${RESET}"
        return
    fi
    
    local count=0
    local ports=()
    
    while read -r port; do
        if [[ -n "$port" ]]; then
            ports+=("$port")
            ((count++))
        fi
    done < "$PID_FILE"
    
    if [[ $count -eq 0 ]]; then
        echo "${RED}No forwards${RESET}"
    elif [[ $count -le 3 ]]; then
        # Show individual ports if 3 or fewer
        local port_list=""
        for port in "${ports[@]}"; do
            port_list+="$port "
        done
        echo "${GREEN}⇄ ${port_list}${RESET}"
    else
        # Show count if more than 3
        echo "${GREEN}⇄ ${count} ports${RESET}"
    fi
}

# Check for auto-detectable servers
check_servers() {
    local COMMON_PORTS=(3000 3001 4000 5000 5173 8000 8080 8888 9000)
    local running=0
    
    for port in "${COMMON_PORTS[@]}"; do
        if command -v nc >/dev/null 2>&1; then
            if nc -z localhost "$port" 2>/dev/null; then
                ((running++))
            fi
        fi
    done
    
    if [[ $running -gt 0 ]]; then
        echo "${YELLOW}${running} dev${RESET}"
    fi
}

# Main output for tmux status
case "${1:-status}" in
    status)
        get_port_status
        ;;
    servers)
        check_servers
        ;;
    combined)
        local forwards=$(get_port_status)
        local servers=$(check_servers)
        if [[ -n "$servers" ]]; then
            echo "$forwards $servers"
        else
            echo "$forwards"
        fi
        ;;
esac