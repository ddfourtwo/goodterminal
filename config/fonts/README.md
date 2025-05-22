# Font Configuration

GoodTerminal uses **JetBrainsMono Nerd Font** for optimal developer experience with excellent readability and icon support for tmux, nvim, and other tools.

## Font Details

- **Font**: JetBrainsMono Nerd Font (designed specifically for developers)
- **Size**: 12pt (optimal for code readability)
- **Features**: 
  - Programming ligatures for better code readability
  - Nerd Font icons for file types, git status, etc.
  - Excellent readability over SSH connections
  - Optimized for long coding sessions

## Installation

The font is automatically installed when you run:

```bash
./install.sh --install
# or
./install.sh --update
```

## Manual Installation

If you need to install just the font:

```bash
./config/fonts/install-fonts.sh
```

## Terminal Configuration

### iTerm2 (macOS)

1. Import the provided profile:
   - iTerm2 → Preferences → Profiles
   - Click the dropdown next to the + button
   - Select "Import JSON Profiles..."
   - Choose `config/iterm2/GoodTerminal-VSCode-Profile.json`

2. Or configure manually:
   - Font: `JetBrainsMono Nerd Font`
   - Size: `12`
   - Character Spacing: `1.0`
   - Line Spacing: `1.1`

### Other Terminals

Configure your terminal to use:
- **Font Family**: `JetBrainsMono Nerd Font` (or `JetBrains Mono NF`)
- **Font Size**: `12`
- **Line Height**: `1.5` (if available)

## Verification

After installation, verify the font is working:

1. **Nerd Font Icons**: Run `echo "  "` - you should see folder and file icons
2. **Programming Ligatures**: Type `->`, `==`, `!=` - they should connect visually
3. **Readability**: Text should be crisp and easy to read at size 12

## Troubleshooting

### Font Not Found

If the terminal can't find the font:

- **macOS**: Check `~/Library/Fonts/` contains `JetBrainsMonoNerdFont-*.ttf`
- **Linux**: Check `~/.fonts/` contains the font files
- Restart your terminal application
- On Linux, run `fc-cache -fv` to refresh font cache

### Icons Not Displaying

If you see squares or missing characters:
- Ensure you selected the "Nerd Font" version (not the regular Cascadia Code)
- Verify terminal supports UTF-8 encoding
- Check terminal's font fallback settings

### SSH Issues

If fonts look different over SSH:
- Ensure `TERM=xterm-256color` is set on remote
- Verify SSH client forwards font information
- Use the same font configuration on all machines

## Font Files

The following files are installed:

- `JetBrainsMonoNerdFont-Regular.ttf`
- `JetBrainsMonoNerdFont-Bold.ttf` 
- `JetBrainsMonoNerdFont-Italic.ttf`
- `JetBrainsMonoNerdFont-BoldItalic.ttf`

## Alternative Fonts

If you prefer a different font, good alternatives include:

- `CascadiaCode Nerd Font` - Microsoft's VSCode default
- `FiraCode Nerd Font` - Popular with extensive ligatures
- `Hack Nerd Font` - Clean and readable

To change fonts, modify the font installation script and update the iTerm2 profile.