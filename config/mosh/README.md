# Mosh Configuration

Mosh (mobile shell) doesn't use a traditional configuration file like tmux or vim. Instead, configuration is done through:

1. Environment variables
2. Command-line options
3. Shell aliases and functions

## Usage

The `config` file in this directory contains:
- Recommended environment variables for mosh
- Useful shell functions and aliases
- Settings for better integration with tmux

To use these settings, source the config file in your shell profile:

```bash
# Add to ~/.bashrc or ~/.zshrc
source /path/to/goodterminal/config/mosh/config
```

## Key Features

- `mosh_tmux` function: Easily connect to a remote server and attach to a tmux session
- `mosh_cleanup` function: Clean up old mosh-server processes
- Aliases for common mosh operations
- Optimized timeout and display settings
- Full clipboard integration with tmux-yank (OSC 52 support)

## Example Usage

```bash
# Connect to a server with tmux
mosh_tmux myserver.com work

# List all mosh processes
mosh-list

# Clean up old sessions
mosh_cleanup
```
