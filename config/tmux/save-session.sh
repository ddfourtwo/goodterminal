#!/bin/bash

# Save current tmux session to .twm.yaml file
# This script captures the current session layout and generates a TWM config

set -e

# Get current session name and directory
SESSION_NAME=$(tmux display-message -p '#S')
SESSION_PATH=$(tmux display-message -p '#{pane_current_path}')

# Check if we're in a valid directory
if [[ ! -d "$SESSION_PATH" ]]; then
    tmux display-message "Error: Invalid session path: $SESSION_PATH"
    exit 1
fi

# Output file
OUTPUT_FILE="$SESSION_PATH/.twm.yaml"

# Check if file already exists
if [[ -f "$OUTPUT_FILE" ]]; then
    tmux command-prompt -p "File exists. Overwrite? (y/n)" "run-shell 'if [[ \"%%\" == \"y\" ]]; then $0 force; else tmux display-message \"Cancelled\"; fi'"
    if [[ "$1" != "force" ]]; then
        exit 0
    fi
fi

# Get list of windows in current session
WINDOWS=$(tmux list-windows -t "$SESSION_NAME" -F '#{window_index}:#{window_name}:#{window_active}')

# Start building the YAML content
cat > "$OUTPUT_FILE" << EOF
# Generated TWM configuration for session: $SESSION_NAME
# Created: $(date)

layout: "saved"

layouts:
  saved:
EOF

# Process each window
while IFS=':' read -r window_index window_name is_active; do
    # Get the command running in the first pane of this window
    PANE_COMMAND=$(tmux list-panes -t "$SESSION_NAME:$window_index" -F '#{pane_current_command}' | head -n1)
    
    # Skip tmux itself
    if [[ "$PANE_COMMAND" == "tmux" ]]; then
        PANE_COMMAND=""
    fi
    
    echo "    - name: \"$window_name\"" >> "$OUTPUT_FILE"
    
    # Add command if it's not just a shell
    if [[ -n "$PANE_COMMAND" && "$PANE_COMMAND" != "zsh" && "$PANE_COMMAND" != "bash" && "$PANE_COMMAND" != "sh" ]]; then
        echo "      command: \"$PANE_COMMAND\"" >> "$OUTPUT_FILE"
    fi
    
    # Mark the currently active window
    if [[ "$is_active" == "1" ]]; then
        echo "      focus: true" >> "$OUTPUT_FILE"
    fi
    
done <<< "$WINDOWS"

# Add some common settings
cat >> "$OUTPUT_FILE" << EOF

# Customize these settings as needed
settings:
  session_name: "$SESSION_NAME"
  window_title: "$(basename "$SESSION_PATH")"

# Add environment variables if needed
# env:
#   NODE_ENV: "development"
#   DEBUG: "*"
EOF

tmux display-message "Session saved to .twm.yaml in $SESSION_PATH"