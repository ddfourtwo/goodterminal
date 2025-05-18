# GoodTerminal

Transform any server into a powerful command-line development environment with a single install command. GoodTerminal provides a complete, modern terminal setup with seamless integration between tmux, neovim, and mosh for the ultimate remote development experience.

## 🎯 Purpose

GoodTerminal is designed for developers who work on remote servers and want a consistent, productive command-line environment everywhere. Instead of manually configuring each server, run one command to get:

- **Modern Neovim** with LSP support, fuzzy finding, and autocompletion
- **Enhanced Tmux** with persistent sessions and smart navigation
- **Mosh integration** for reliable connections that survive network changes
- **Seamless navigation** between tmux panes and nvim splits

## 🚀 Quick Start

```bash
# SSH into your server
ssh yourserver.com

# Clone and install GoodTerminal
git clone https://github.com/yourusername/goodterminal.git
cd goodterminal
./install.sh

# Select option 1 for full installation
# In minutes, your server is transformed!
```

### First-time AI Setup
After installation, set up the AI tools:

1. **AI Autocompletion in Neovim**:
```bash
nvim                    # Open neovim
:Codeium Auth          # Run the auth command
# Follow instructions to authenticate with Codeium
```

2. **Claude Code CLI**:
```bash
claude auth            # Authenticate with Anthropic
claude help            # View available commands
```

## 🌟 Features

### Single-Command Setup
- Installs latest versions of mosh, tmux, neovim, zsh, and Claude Code
- Configures all tools with modern defaults
- Sets up all plugins automatically
- Works on Ubuntu, Debian, RHEL, CentOS, Arch, and macOS

### Seamless Integration
- **Unified Navigation**: Use `<C-h/j/k/l>` to move between tmux panes AND neovim splits
- **Smart Context Switching**: Automatically detects whether you're in tmux or nvim
- **Consistent Keybindings**: Same shortcuts work everywhere

### Modern Development Environment
- **AI Autocompletion**: Codeium's Windsurf for intelligent code suggestions
- **LSP Support**: Full language server protocol for Python, JavaScript, TypeScript, Bash, and more
- **Fuzzy Finding**: Telescope for fast file and content searching
- **Syntax Highlighting**: Treesitter for accurate code highlighting
- **Git Integration**: Visual git workflow with lazygit, plus gitsigns in editor
- **File Explorer**: Navigate projects with nvim-tree

### Reliable Remote Work
- **Persistent Sessions**: Never lose work with tmux session management
- **Connection Resilience**: Mosh maintains sessions through network interruptions
- **Quick Reconnect**: `mosh_tmux` function for instant session resumption

## 📋 What's Included

### Neovim Configuration
- AI-powered autocompletion with Windsurf (Codeium)
- Full LSP setup with traditional autocompletion
- Telescope for fuzzy finding
- Treesitter for syntax highlighting
- File explorer with nvim-tree
- Git integration with lazygit and gitsigns
- Beautiful OneDark theme
- Leader key: `<Space>`
- Git commands: `<leader>gg` for lazygit
- AI completion: `Tab` to accept, `Ctrl-e` to dismiss

### Tmux Configuration
- Mouse support
- Intuitive pane/window management
- Session persistence
- Modern Dracula theme with system monitoring
- Prefix key: ` (backtick)

### Mosh Configuration
- Extended timeout settings
- Helper functions for tmux integration
- Cleanup utilities

### Shell Configuration  
- Enhanced oh-my-zsh with custom plugins:
  - Beautiful prompts with git information
  - Real-time syntax highlighting (zsh-syntax-highlighting plugin)
  - Intelligent command autosuggestions (zsh-autosuggestions plugin)
  - Interactive cd with directory preview (zsh-interactive-cd plugin with fzf)
  - Smart tab completion with visual menu
  - Directory navigation shortcuts
  - Command history search
  - Automatic command corrections
  - Popular plugins enabled: git, docker, npm, python, tmux, and more
- Key bindings:
  - `Ctrl+Right` or `Alt+f`: Accept autosuggestion
  - `Ctrl+Left/Right`: Navigate words
- Enhanced bash completion for non-zsh users
- Useful aliases and shortcuts
- Better history management
- Essential helper functions

### AI-Powered Tools
- AI code autocompletion with Windsurf in neovim
- Claude Code CLI for AI assistance in terminal
- Easy authentication for both tools

## 🔧 Usage

### Keyboard Shortcuts
For a complete list of keyboard shortcuts and keybindings, see [KEYBINDINGS.md](KEYBINDINGS.md).

**Note**: Tmux uses backtick (`) as the prefix key instead of the default Ctrl-b.

### Interactive Menu (Recommended)
```bash
./install.sh
```

Options:
1. Full installation (first-time setup)
2. Update configurations and plugins
3. Update system packages only
4. Update everything
5. Check health status

### Command-Line Options
```bash
./install.sh --install     # Full installation
./install.sh --update      # Update configs and plugins
./install.sh --update-all  # Update everything
./install.sh --health      # Check health status
```

## 🗺️ Navigation Guide

The killer feature is seamless navigation:

- **`<C-h/j/k/l>`**: Move left/down/up/right between:
  - tmux panes (when in terminal)
  - neovim splits (when in editor)
  - Automatically switches context!

- **Additional tmux navigation**:
  - `Alt+arrows`: Navigate panes
  - `Shift+arrows`: Switch windows
  - `Alt+H/L`: Previous/next window

## 📁 Directory Structure

```
goodterminal/
├── install.sh           # Main installation/update script
├── config/
│   ├── nvim/           # Neovim configuration
│   ├── tmux/           # Tmux configuration
│   ├── mosh/           # Mosh configuration
│   └── shell/          # Shell enhancements (bash/zsh)
├── CLAUDE.md           # Detailed documentation
├── LICENSE             # MIT License
└── README.md           # This file
```

## 🔄 Keeping Updated

The same script handles updates:

```bash
cd /path/to/goodterminal
./install.sh --update      # Update configs and plugins
./install.sh --update-all  # Update everything
```

## 🛠️ Requirements

- Git
- Curl or wget  
- Build tools (for compiling)
- Internet connection
- Supported OS: Ubuntu, Debian, RHEL, CentOS, Arch Linux, or macOS

## 🐛 Troubleshooting

### Neovim plugins not loading
- Run `:Lazy install` inside neovim
- Check `:checkhealth` for issues

### Tmux plugins not working
- Press `<prefix>I` (` + I) to install plugins
- Restart tmux

### Navigation not working
- Ensure vim-tmux-navigator is installed in both tmux and nvim
- Restart both applications

## 🔑 Key Concepts

### Understanding Leader Key
- The `<leader>` key is a prefix key in vim/neovim (like Ctrl or Alt)
- We set it to `<Space>` (the spacebar)
- So `<leader>gg` means: press Space, then press g twice
- Example: `<leader>ff` = Space + f + f (opens file finder)

### Vim Motion Keys
- `h/j/k/l` = left/down/up/right (like arrow keys)
- `<C-h>` means Ctrl+h
- These work in both vim and tmux for seamless navigation

### Tmux Prefix
- The prefix key in tmux is ` (backtick)
- For tmux commands: press ` (backtick), then press the next key
- Example: `<prefix>r` = `, then r (reloads config)

## 🔗 Tools & Technologies

Here are all the tools included in GoodTerminal with links to their repositories:

### Core Tools
- [Neovim](https://github.com/neovim/neovim) - Hyperextensible Vim-based text editor
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer
- [mosh](https://github.com/mobile-shell/mosh) - Mobile shell for intermittent connectivity
- [zsh](https://github.com/zsh-users/zsh) - Powerful shell with better completion

### Neovim Plugins
- [Lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin manager
- [Windsurf](https://github.com/Exafunction/windsurf.vim) - AI autocompletion by Codeium
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - LSP configuration
- [Mason.nvim](https://github.com/williamboman/mason.nvim) - LSP server installer
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) - Completion engine
- [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Fuzzy finder
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Syntax highlighting
- [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) - File explorer
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) - Git decorations
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) - Status line
- [Comment.nvim](https://github.com/numToStr/Comment.nvim) - Easy commenting
- [nvim-autopairs](https://github.com/windwp/nvim-autopairs) - Auto close brackets
- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) - Seamless navigation
- [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim) - Lazygit integration
- [onedark.nvim](https://github.com/navarasu/onedark.nvim) - Color scheme

### Tmux Plugins
- [tpm](https://github.com/tmux-plugins/tpm) - Tmux Plugin Manager
- [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) - Basic settings
- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) - Seamless navigation
- [tmux-yank](https://github.com/tmux-plugins/tmux-yank) - System clipboard support

### Additional Tools
- [lazygit](https://github.com/jesseduffield/lazygit) - Terminal UI for git
- [ripgrep](https://github.com/BurntSushi/ripgrep) - Fast text search
- [Claude Code](https://github.com/anthropics/claude-code) - Anthropic's official CLI for Claude

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

## 📄 License

MIT License - see LICENSE file for details

---

**Transform your remote development experience with GoodTerminal - because every server deserves a modern terminal environment!**