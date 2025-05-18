# Shell Configuration

Lightweight shell enhancements for both bash and zsh, focusing on:
- Auto-completion
- Useful aliases
- Better history management
- Simple git-aware prompt
- Essential functions

## Features

### Universal (works in both bash and zsh)
- Better history with deduplication
- Helpful aliases for common tasks
- Git shortcuts that don't conflict with oh-my-zsh
- Directory navigation helpers
- Archive extraction function
- Quick backup function
- Create and enter directory function (mkcd)

### ZSH Specific
- Advanced completion with case-insensitive matching
- Partial completion suggestions
- History search with arrow keys
- Auto-cd (type directory name to cd into it)
- Shared history between sessions

### Bash Specific
- Programmable completion
- History search with arrow keys
- Spell correction for cd command
- Case-insensitive globbing

## Usage

The shell configuration is automatically sourced by the install script. It adds a line to your shell profile:

```bash
source /path/to/goodterminal/config/shell/config
```

## Customization

Create a `~/.shell_local` file for personal customizations that won't be overwritten by updates.

## Performance

This configuration is designed to be lightweight and fast, adding minimal overhead to shell startup time - perfect for remote servers.
