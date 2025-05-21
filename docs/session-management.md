# Session Management in GoodTerminal

GoodTerminal includes powerful session management for both tmux and Neovim, allowing you to seamlessly resume your work exactly where you left off.

## Tmux Session Management with TWM

[TWM (Tmux Workspace Manager)](https://github.com/vinnymeller/twm) manages tmux workspaces based on project directories, making it easy to organize and restore your terminal environment.

### Key Features

- Project directory detection based on configurable patterns
- Quick switching between workspaces via interactive picker
- Customizable layouts for different project types
- Project-specific configurations

### Keybindings

GoodTerminal sets up the following tmux keybindings for TWM:

- **`` ` w ``**: Open the TWM workspace picker
- **`` ` W ``**: Open TWM and select a layout
- **`` ` T ``**: Attach to existing tmux sessions

### How to Quit Tmux While Preserving Sessions

To detach from tmux (preserving your session):

1. Press the tmux prefix key (`` ` `` in GoodTerminal)
2. Press `d`

Your session will remain active in the background. When you want to reconnect:

- Use `twm -e` to see and select existing sessions
- Or use `` ` T `` from within tmux
- Or use `tmux attach` to connect to the last session
- Or use `tmux attach -t session_name` to connect to a specific session

### Project-Specific Configuration

You can create a `.twm.yaml` file in your project directory to set up a custom workspace whenever you open that project:

```yaml
# Example .twm.yaml for a web project
layout: "custom"

layouts:
  custom:
    # Main editor window
    - name: "editor"
      command: "nvim"
    # Server window that runs a development server
    - name: "server"
      command: "npm start"
    # Test window for running tests
    - name: "tests"
      command: "echo 'Run tests with: npm test'"

env:
  NODE_ENV: "development"
```

When you navigate to this project using TWM, it will automatically set up your tmux session with these windows and commands.

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

The combination of TWM and persistence.nvim creates a powerful workflow:

1. Use TWM to organize and manage your tmux sessions by project
2. Use persistence.nvim to automatically save and restore your Neovim state within each project
3. Move between projects seamlessly while maintaining your complete environment

This allows you to easily switch between multiple projects, each with its own terminal layout and editor state, without losing any context.