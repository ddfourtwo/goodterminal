# Tmux Configuration

This directory contains the tmux configuration for GoodTerminal.

## Features

- **Prefix Key**: ` (backtick) - Easy to reach and doesn't conflict with common shortcuts
- **Modern Colorscheme**: Dracula theme with system monitoring (CPU, RAM, time)
- **Seamless Navigation**: Works with vim-tmux-navigator for unified movement
- **Mouse Support**: Full mouse integration enabled
- **Smart Splits**: New panes and windows open in the current directory

## Key Bindings

See [KEYBINDINGS.md](../../KEYBINDINGS.md) for the complete list of keyboard shortcuts.

## Colorscheme

The default colorscheme is **Dracula**, which provides:
- Beautiful dark purple theme
- System monitoring widgets
- Powerline-style status bar
- Session information display

### Alternative Themes

You can easily switch to other themes by editing `tmux.conf`:

1. Comment out the Dracula plugin line
2. Uncomment one of the alternatives:
   - **Nord**: Arctic-inspired blue theme
   - **Gruvbox**: Retro groove dark theme
   - **Solarized**: Precision colors (light/dark)
   - **tmux-power**: Powerline with multiple colors

### Installing Theme Changes

After changing the theme in `tmux.conf`:
1. Reload config: `` ` r``
2. Install new plugins: `` ` I``
3. Restart tmux if needed

## Customization

Feel free to modify `tmux.conf` to suit your preferences. Common customizations:

- Change the prefix key
- Adjust status bar elements
- Modify colorscheme settings
- Add custom key bindings

## Plugins

Managed by TPM (Tmux Plugin Manager):
- `tmux-sensible`: Better defaults
- `vim-tmux-navigator`: Seamless pane navigation
- `tmux-yank`: Better copy/paste
- `dracula/tmux`: Beautiful colorscheme

To update plugins: `` ` U``