# Neovim Session Management with persistence.nvim

GoodTerminal's Neovim setup includes `persistence.nvim`, which automatically saves and restores your sessions when you reopen Neovim in the same directory.

## How It Works

- **Automatic Session Saving**: When you quit Neovim, your session is automatically saved
- **Directory-Based Sessions**: Sessions are tied to the directory you're working in
- **Automatic Restoration**: When you open Neovim in the same directory, your session will be restored
- **What's Saved**: Open buffers, window layout, cursor positions, and more

## Keybindings

| Keybinding   | Action                           |
|--------------|----------------------------------|
| `<leader>qs` | Restore session for current dir  |
| `<leader>ql` | Restore last session             |
| `<leader>qd` | Don't save current session       |

Note: `<leader>` is set to Space in GoodTerminal's Neovim config.

## Usage Tips

1. **Working on Multiple Projects**:
   - Sessions are saved per directory
   - You can switch between projects and each will maintain its own session

2. **Starting Fresh**:
   - Use `<leader>qd` to prevent saving the current session
   - Or use `nvim --clean` to start without loading any session

3. **Manual Session Management**:
   - Use `<leader>qs` to manually restore a session if needed
   - Use `<leader>ql` to load the very last session you were in

## What Gets Saved

- Open buffers
- Window layout and sizes
- Tab pages
- Current working directory
- Cursor positions
- Terminal buffers (in normal mode)

## Session Storage Location

Sessions are stored in: `~/.local/state/nvim/sessions/`