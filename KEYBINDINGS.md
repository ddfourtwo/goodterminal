# GoodTerminal Keybindings Cheat Sheet

## Leader Key
- **Leader**: `<space>` (spacebar)
- All `<leader>` commands start with pressing the spacebar

## Essential Navigation

### Pane/Window Navigation (Works in nvim AND tmux!)
- `Ctrl-h` - Move to left pane
- `Ctrl-j` - Move to down pane
- `Ctrl-k` - Move to up pane  
- `Ctrl-l` - Move to right pane

### Buffer Navigation
- `Tab` - Next buffer
- `Shift-Tab` - Previous buffer
- `<space>1-9` - Jump to buffer 1-9
- `<space>bn` - Next buffer
- `<space>bp` - Previous buffer
- `<space>bd` - Delete/close current buffer

## File Management

### File Tree
- `<space>e` - Toggle file tree
- In file tree:
  - `Enter` - Open file
  - `Ctrl-]` - Change root to folder
  - `-` - Go up one directory
  - Standard vim navigation (`h,j,k,l`)

### Finding Files
- `<space>ff` - Find files (fuzzy finder)
- `<space>fg` - Find in files (live grep)
- `<space>fb` - Find open buffers
- `<space>fh` - Find help tags

## Window Management

### Creating Splits
- `<space>v` - Vertical split
- `<space>h` - Horizontal split

### Resizing Windows
- `Ctrl-Up` - Resize window up
- `Ctrl-Down` - Resize window down
- `Ctrl-Left` - Resize window left
- `Ctrl-Right` - Resize window right

### Window Commands
- `<space>w` - Switch between windows
- `<space>q` - Quit current window
- `<space>x` - Save and quit current window
- `<space>qa` - Quit all (preserves session)
- `<space>xa` - Save and quit all (preserves session)

## Coding Features

### LSP (Language Server)
- `gd` - Go to definition
- `gr` - Go to references
- `K` - Hover for documentation
- `<space>ca` - Code actions
- `<space>rn` - Rename symbol
- `<space>f` - Format file

### Git
- `<space>gg` - Open LazyGit
- `<space>gc` - LazyGit config

### Comments
- `gcc` - Toggle comment on current line
- `gc` - Toggle comment (visual mode)
- `gcO` - Add comment above
- `gco` - Add comment below

## Session Management
- `<space>ss` - Save current session
- `<space>sl` - Load session for current directory
- `<space>sd` - Stop session recording
- Sessions auto-save on exit and auto-restore when opening nvim

## Other Useful Commands
- `<space>nh` - Clear search highlighting

---

## Tmux Integration (when in tmux)

### Tmux Prefix
- **Prefix**: `` ` `` (backtick)

### Essential Tmux Commands
- `` ` c `` - New window
- `` ` n `` - Next window
- `` ` p `` - Previous window
- `` ` d `` - Detach from session
- `` ` s `` - List sessions
- `` ` % `` - Split vertically
- `` ` " `` - Split horizontally
- `` ` [ `` - Enter copy mode
- `` ` ] `` - Paste

### Tmux Copy Mode
1. Enter copy mode: `` ` [ ``
2. Navigate with vim keys (`h,j,k,l`)
3. Start selection: `v`
4. Copy selection: `y`
5. Exit copy mode: `q`
6. Paste: `` ` ] ``

### More Tmux Commands
- `` ` t``: Create new window (tab)
- `` ` <number>``: Jump to window by number (e.g., `` ` 2``)
- `` ` ,``: Rename current window
- `` ` &``: Kill current window (will prompt)
- `Shift+Left/Right`: Previous/next window (no prefix needed)
- `` ` |``: Split vertically (new pane on right)
- `` ` -``: Split horizontally (new pane below)
- `` ` x``: Kill current pane (will prompt)
- `` ` z``: Toggle pane zoom (fullscreen)
- `` ` o``: Cycle through panes
- `` ` ;``: Toggle between last two panes
- `` ` q``: Show pane numbers
- `` ` {`` or `` ` }``: Swap pane position
- `` ` $``: Rename session
- `` ` (``: Switch to previous session
- `` ` )``: Switch to next session
- `` ` r``: Reload tmux configuration
- `` ` M``: Toggle mouse mode (useful for nested tmux sessions)
- `` ` t``: Show clock
- `` ` ?``: List all keybindings
- `` ` I``: Install plugins (via TPM)
- `` ` U``: Update plugins
- `` ` `` ` ``: Send literal backtick
- `` ` Enter``: Send a newline in Claude Code

## Shell (Oh-My-Zsh)

### Command Line
- `Ctrl+a`: Move to beginning of line
- `Ctrl+e`: Move to end of line
- `Ctrl+w`: Delete word backward
- `Alt+d`: Delete word forward
- `Ctrl+k`: Delete to end of line
- `Ctrl+u`: Delete to beginning of line

### Autosuggestions
- `Ctrl+Right`: Accept autosuggestion
- `Alt+f`: Accept autosuggestion
- `Tab`: Complete command
- `Ctrl+r`: Search command history

### Fuzzy Search (fzf)
- `Ctrl+r`: Fuzzy search command history
- `Ctrl+t`: Fuzzy search files
- `Alt+c`: Fuzzy search directories
- `**<Tab>`: Trigger fuzzy completion

---

## Tips & Quick Reference

### Quick Workflow
1. Open nvim in project folder
2. `<space>e` to see file tree
3. `<space>ff` to quickly find files
4. `Tab`/`Shift-Tab` to switch between open files
5. `<space>gg` for git operations
6. `<space>qa` to quit and auto-save session

### Navigation Flow
- Use `Ctrl-h/j/k/l` to seamlessly move between:
  - File tree and editor
  - Multiple splits
  - Even tmux panes (if using tmux)

### Session Workflow
- Just work normally - sessions auto-save on exit
- Return to same folder and run `nvim` - everything restored!
- Use `<space>ss` to manually save important states

### VSCode Users Quick Reference
If you're coming from VSCode, here's the equivalent commands:
- `Cmd/Ctrl+P` → `<space>ff` (find files)
- `Cmd/Ctrl+Shift+F` → `<space>fg` (search in files)
- `Cmd/Ctrl+B` → `<space>e` (toggle sidebar/file tree)
- `F12` → `gd` (go to definition)
- `Shift+F12` → `gr` (find references)
- `Cmd/Ctrl+.` → `<space>ca` (quick fix/code action)

### Remember
1. **Leader key = Spacebar**: All `<leader>` commands start with space
2. **Seamless Navigation**: `Ctrl-h/j/k/l` works across both tmux panes and neovim splits
3. **Prefix Alternative**: If backtick is hard to reach, you can change it in `~/.tmux.conf`
4. **Learning More**: Use `` ` ?`` in tmux and `:help` in neovim to explore more commands