# GoodTerminal Keyboard Shortcuts

## Tmux (Terminal Multiplexer)

**Prefix key: ` (backtick)**

### Windows (Tabs)
- `` ` t``: Create new window (tab)
- `` ` n``: Next window
- `` ` p``: Previous window
- `` ` <number>``: Jump to window by number (e.g., `` ` 2``)
- `` ` w``: List all windows
- `` ` ,``: Rename current window
- `` ` &``: Kill current window (will prompt)
- `Shift+Left/Right`: Previous/next window (no prefix needed)
- `Cmd+Right` (Mac): Next window (configure terminal to map Cmd to Alt)
- `Cmd+Left` (Mac): Previous window (configure terminal to map Cmd to Alt)
- `Cmd+T` (Mac): Create new window (configure terminal to map Cmd to Alt)
- `Cmd+W` (Mac): Kill current window (configure terminal to map Cmd to Alt)

### Panes (Splits)
- `` ` |``: Split vertically (new pane on right)
- `` ` -``: Split horizontally (new pane below)
- `` ` %``: Alternative vertical split
- `` ` "``: Alternative horizontal split
- `` ` x``: Kill current pane (will prompt)
- `` ` z``: Toggle pane zoom (fullscreen)
- `` ` o``: Cycle through panes
- `` ` ;``: Toggle between last two panes
- `` ` q``: Show pane numbers
- `` ` {`` or `` ` }``: Swap pane position

### Navigation
- `Ctrl-h/j/k/l`: Move between panes (seamless with vim!)
- `Alt+Arrow keys`: Move between panes (no prefix)
- `` ` h/j/k/l``: Move between panes (with prefix)

### Sessions
- `` ` d``: Detach from session
- `` ` s``: List sessions
- `` ` $``: Rename session
- `` ` (``: Switch to previous session
- `` ` )``: Switch to next session

### Other Commands
- `` ` r``: Reload tmux configuration
- `` ` t``: Show clock
- `` ` ?``: List all keybindings
- `` ` I``: Install plugins (via TPM)
- `` ` U``: Update plugins
- `` ` `` ` ``: Send literal backtick
- `` ` Enter``: Send a newline in Claude Code

## Neovim

### General
- `<Space>`: Leader key
- `<leader>w`: Save file (Space + w)
- `<leader>q`: Quit (Space + q)
- `<leader>x`: Save and quit

### File Navigation
- `<leader>f`: Open file finder (fuzzy search)
- `<leader>e`: Toggle file explorer
- `<leader>b`: List open buffers
- `<leader>h`: Search help
- `[b` / `]b`: Previous/next buffer
- `<leader>bd`: Close buffer

### Code Navigation
- `gd`: Go to definition
- `gr`: Find references
- `gi`: Go to implementation
- `K`: Show hover documentation
- `<leader>rn`: Rename symbol
- `<leader>ca`: Code actions

### Git Integration
- `<leader>gg`: Open lazygit
- `<leader>gh`: Preview git hunk
- `<leader>gb`: Git blame
- `[c` / `]c`: Previous/next git change

### Search and Replace
- `<leader>lg`: Live grep (search in files)
- `<leader>fw`: Search current word
- `<leader>ps`: Project search
- `:%s/old/new/g`: Replace in file

### AI Features
- `Tab`: Accept AI suggestion
- `Ctrl-e`: Dismiss AI suggestion
- `:Codeium Auth`: Setup AI autocompletion

### Window Management
- `<leader>sv`: Split vertically
- `<leader>sh`: Split horizontally
- `<leader>se`: Make splits equal
- `<leader>sx`: Close current split
- `Ctrl-h/j/k/l`: Navigate between splits/panes

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

## Tips

1. **Seamless Navigation**: `Ctrl-h/j/k/l` works across both tmux panes and neovim splits
2. **Quick Commands**: Most commands in neovim use `<Space>` as the leader key
3. **Prefix Alternative**: If backtick is hard to reach, you can change it in `~/.tmux.conf`
4. **Learning**: Use `` ` ?`` in tmux and `:help` in neovim to explore more commands