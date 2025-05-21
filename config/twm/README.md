# TWM - Tmux Workspace Manager for GoodTerminal

TWM is a tool that manages tmux workspaces based on project directories. It's designed to help you quickly navigate between projects while maintaining your tmux sessions.

## Features

- Automatically identifies project directories (workspaces) based on configurable patterns
- Quick switching between workspaces via an interactive picker
- Creates and manages tmux sessions with customizable layouts
- Supports local project-specific configuration
- Sets environment variables in each workspace for scripting

## Usage

- **`twm`**: Open interactive workspace picker
- **`twm -e`**: Attach to existing tmux sessions
- **`twm -l`**: Select a layout for the workspace
- **`twm -p PATH`**: Open workspace at specific path
- **`twm -g`**: Group with existing sessions
- **`twm -d`**: Create session without attaching to it

## Keybindings

GoodTerminal sets up the following tmux keybindings for TWM:

- **`` ` w ``**: Open the TWM workspace picker
- **`` ` W ``**: Open TWM and select a layout
- **`` ` T ``**: Attach to existing tmux sessions

## How to Quit Tmux While Preserving Sessions

To detach from tmux (preserving your session):

1. Press the tmux prefix key (`` ` `` in GoodTerminal)
2. Press `d`

Your session will remain active in the background. When you want to reconnect:

- Use `twm -e` to see and select existing sessions
- Or use `tmux attach` to connect to the last session
- Or use `tmux attach -t session_name` to connect to a specific session

## Configuration

TWM uses a configuration file at `~/.config/twm/twm.yaml`. GoodTerminal provides a default configuration, but you can modify it to suit your needs.

Key settings include:

- `search_paths`: Where TWM looks for workspaces
- `workspace_patterns`: Files/dirs that identify a workspace
- `layouts`: Define custom tmux window/pane arrangements
- `session_name_settings`: Control how session names are generated

## Project-Specific Configuration

You can add a `.twm.yaml` file to any project directory to set project-specific configuration.