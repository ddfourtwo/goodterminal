# GoodTerminal Documentation

This directory contains comprehensive documentation for the GoodTerminal project.

## Quick Start

New to GoodTerminal? Start here:
1. [PURPOSE.md](PURPOSE.md) - Understand what GoodTerminal is and who it's for
2. [ARCHITECTURE.md](ARCHITECTURE.md) - Learn how the system is designed
3. [../KEYBINDINGS.md](../KEYBINDINGS.md) - Master the keyboard shortcuts

## Core Documentation

### Project Overview
- **[PURPOSE.md](PURPOSE.md)** - Project goals, target users, and problems solved
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture, component interactions, and technical decisions

### Installation & Setup
- **[../README.md](../README.md)** - Main README with installation instructions
- **[troubleshooting/](troubleshooting/)** - Common issues and solutions

### Configuration
- **[../config/](../config/)** - All configuration files organized by tool
  - `nvim/` - Neovim configuration with Lazy.nvim
  - `tmux/` - Tmux configuration with TPM
  - `shell/` - Zsh/Bash shell enhancements
  - `mosh/` - Mosh configuration
  - `lazygit/` - LazyGit configuration
  - `fonts/` - Font installation scripts
  - `iterm2/` - iTerm2 settings

### Development

#### Planning & Requirements
- **[plans/](plans/)** - Product requirement documents and feature plans
- **[../prd.md](../prd.md)** - Current product requirements document

#### Implementation
- **[tasks/](tasks/)** - Task documents used as context for sub-agents
- **[implementations/](implementations/)** - Final implementation details for completed features

#### Standards & Procedures
- **[sop/](sop/)** - Standard operating procedures for common tasks
- **[../CLAUDE.md](../CLAUDE.md)** - Development rules and AI agent guidelines

### Reference
- **[design_system/](design_system/)** - Design system and UI guidelines (if applicable)
- **[archive/](archive/)** - Historical documents and deprecated documentation

## Additional Resources

### Scripts & Utilities
- **[../scripts/](../scripts/)** - Utility scripts
  - `port-forward.sh` - Advanced port forwarding utilities
  - `setup-port-forwarding.sh` - Port forwarding initialization

### Session Management
- Session management documentation (see troubleshooting/)
- Port forwarding guides (see troubleshooting/)

## Contributing

When adding documentation:
1. Place feature plans in `plans/`
2. Place implementation details in `implementations/`
3. Add SOPs for repeatable processes in `sop/`
4. Update this index when adding new documents
5. Archive outdated documents to `archive/` with timestamps

## Documentation Standards

All documentation should:
- Use clear, concise language
- Include examples where applicable
- Reference actual code with file paths and line numbers
- Keep diagrams up to date with code changes
- Follow the structure defined in CLAUDE.md
