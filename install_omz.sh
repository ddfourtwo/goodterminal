#!/bin/bash
# Install oh-my-zsh with our custom configuration

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log_info "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    log_info "oh-my-zsh already installed"
fi

# Install additional plugins
log_info "Installing oh-my-zsh plugins..."

# zsh-autosuggestions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# zsh-syntax-highlighting
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Create custom oh-my-zsh configuration
cat > ~/.zshrc.goodterminal << 'EOF'
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="robbyrussell"

# Enable plugins
plugins=(git docker docker-compose npm pip python tmux zsh-autosuggestions zsh-syntax-highlighting)

# Plugin configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# User configuration
export EDITOR='nvim'
export VISUAL='nvim'

# Aliases
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias lg='lazygit'

# Load GoodTerminal configurations
[ -f "$HOME/Documents/GitHub/goodterminal/config/shell/config" ] && source "$HOME/Documents/GitHub/goodterminal/config/shell/config"
[ -f "$HOME/Documents/GitHub/goodterminal/config/mosh/config" ] && source "$HOME/Documents/GitHub/goodterminal/config/mosh/config"

# Enable vi mode in command line
bindkey -v

# Better key bindings
bindkey '^R' history-incremental-search-backward
bindkey '^[[1;5C' forward-word  # Ctrl+Right
bindkey '^[[1;5D' backward-word # Ctrl+Left
bindkey '^[[H' beginning-of-line # Home
bindkey '^[[F' end-of-line      # End

# Accept autosuggestions
bindkey '^[[1;5C' autosuggest-accept # Ctrl+Right
bindkey '^[f' autosuggest-accept     # Alt+f
EOF

# Backup existing .zshrc and use our custom one
if [ -f ~/.zshrc ]; then
    mv ~/.zshrc ~/.zshrc.backup
fi
mv ~/.zshrc.goodterminal ~/.zshrc

log_success "oh-my-zsh installed with GoodTerminal configuration!"
log_info "Please start a new shell or run: source ~/.zshrc"