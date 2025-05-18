# GoodTerminal - Single-Install Server Development Environment

## Purpose

GoodTerminal is designed to transform any Linux or macOS server into a powerful command-line development environment with a single installation command. It's specifically built for developers who work on remote servers and want a consistent, modern terminal experience across all their machines.

## What Problems Does This Solve?

1. **Inconsistent Server Environments**: Every time you SSH into a new server, you face a different configuration with basic vim, no modern tools, and poor navigation.

2. **Tedious Manual Setup**: Setting up tmux, neovim, LSP servers, and plugins on each server manually takes hours.

3. **Poor Remote Development Experience**: Default terminal environments lack modern development features like LSP support, fuzzy finding, and seamless navigation.

4. **Lost Connections**: Without mosh, losing SSH connections means losing work and context.

## Key Design Principles

1. **Single Command Installation**: One script sets up everything - no manual intervention needed.

2. **Seamless Integration**: tmux and neovim work together perfectly with unified navigation keys.

3. **Modern Development Features**: Full LSP support, autocompletion, syntax highlighting, and fuzzy finding out of the box.

4. **Cross-Platform**: Works identically on Ubuntu, Debian, RHEL, CentOS, Arch Linux, and macOS.

5. **Resilient Connections**: Mosh integration ensures your sessions survive network changes and disconnections.

## Technical Approach

- **Unified Install Script**: The `install.sh` script handles installation, updates, and health checks with an interactive menu or command-line options.

- **Declarative Configurations**: All configurations are stored in the repository, making them version-controlled and consistent.

- **Plugin Management**: Automatic plugin installation and updates for both tmux (via TPM) and neovim (via Lazy.nvim).

- **Smart Navigation**: vim-tmux-navigator enables seamless movement between tmux panes and neovim splits using the same keybindings (Ctrl-hjkl).

## Typical Use Case

```bash
# SSH into a new server
ssh newserver.com

# Clone and run GoodTerminal
git clone https://github.com/yourusername/goodterminal.git
cd goodterminal
./install.sh

# Choose option 1 for full installation
# Wait a few minutes...

# Done! You now have:
# - Modern neovim with LSP support
# - Tmux with persistent sessions
# - Mosh for reliable connections
# - Seamless navigation between all tools
```

## Why This Matters

Remote development should be as comfortable as local development. GoodTerminal ensures that every server you work on has:

- The same keyboard shortcuts
- The same development tools
- The same productivity features
- The same reliable experience

No more context switching between different server configurations. No more losing work to connection drops. No more settling for basic vim when you could have a full IDE experience in the terminal.

## Maintenance and Updates

The same script that installs also updates:

```bash
./install.sh --update      # Update configurations and plugins
./install.sh --update-all  # Update everything including packages
```

This ensures your development environment stays current across all your servers with minimal effort.