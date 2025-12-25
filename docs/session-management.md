# Session Management in GoodTerminal

GoodTerminal includes powerful session management for both tmux and Neovim, allowing you to seamlessly resume your work exactly where you left off.

## Tmux Session Management

Tmux provides built-in session persistence - your sessions remain active even after you disconnect from the server.

### Key Features

- Sessions persist in the background when you detach
- Multiple named sessions for different projects
- Easy session switching and management
- Sessions survive SSH disconnections

### Keybindings

GoodTerminal sets up the following tmux keybindings:

- **`` ` d ``**: Detach from current session (session continues in background)
- **`` ` s ``**: List and switch between sessions
- **`` ` $ ``**: Rename current session

### How to Quit Tmux While Preserving Sessions

To detach from tmux (preserving your session):

1. Press the tmux prefix key (`` ` `` in GoodTerminal)
2. Press `d`

Your session will remain active in the background. When you want to reconnect:

- Use `tmux ls` to list all sessions
- Use `tmux attach` to connect to the last session
- Use `tmux attach -t session_name` to connect to a specific session

### Creating Named Sessions

Create a session with a name for easy identification:

```bash
tmux new -s myproject
```

This creates a session named "myproject" that you can later attach to with:

```bash
tmux attach -t myproject
```

### Managing Multiple Projects

For multiple projects, create separate named sessions:

```bash
# Create sessions for different projects
tmux new -s frontend -d    # -d creates in detached mode
tmux new -s backend -d
tmux new -s docs -d

# List all sessions
tmux ls

# Attach to a specific session
tmux attach -t frontend
```

## Neovim Session Management

GoodTerminal uses [persistence.nvim](https://github.com/folke/persistence.nvim) to automatically save and restore your Neovim sessions.

### Key Features

- **Automatic Session Saving**: When you quit Neovim, your session is automatically saved
- **Directory-Based Sessions**: Sessions are tied to the directory you're working in
- **Automatic Restoration**: When you open Neovim in the same directory, your session will be restored
- **What's Saved**: Open buffers, window layout, cursor positions, and more

### Keybindings

| Keybinding   | Action                           |
|--------------|----------------------------------|
| `<leader>qs` | Restore session for current dir  |
| `<leader>ql` | Restore last session             |
| `<leader>qd` | Don't save current session       |

Note: `<leader>` is set to Space in GoodTerminal's Neovim config.

### How It Works

When you open Neovim in a directory, persistence.nvim checks if there's a saved session for that directory. If there is, it automatically restores:

- Open buffers
- Window layout and sizes
- Tab pages
- Current working directory
- Cursor positions
- Terminal buffers (in normal mode)

When you quit Neovim, the session is automatically saved for that directory.

If you want to start a fresh session without loading the saved one, use `nvim --clean` or press `<Space>qd` to prevent the current session from being saved.

## Using Both Together

The combination of tmux sessions and persistence.nvim creates a powerful workflow:

1. Use tmux named sessions to organize your terminal sessions by project
2. Use persistence.nvim to automatically save and restore your Neovim state within each project
3. Move between projects seamlessly while maintaining your complete environment

This allows you to easily switch between multiple projects, each with its own terminal layout and editor state, without losing any context.
