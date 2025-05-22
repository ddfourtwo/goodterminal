#!/bin/bash

# Font installation script for GoodTerminal
# Installs Nerd Fonts to match VSCode appearance

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        FONT_DIR="$HOME/Library/Fonts"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        FONT_DIR="$HOME/.fonts"
        mkdir -p "$FONT_DIR"
    else
        log_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Install font on macOS
install_macos_font() {
    local font_url="$1"
    local font_name="$2"
    
    if [ -f "$FONT_DIR/$font_name" ]; then
        log_info "$font_name already installed"
        return 0
    fi
    
    log_info "Installing $font_name..."
    curl -fLo "$FONT_DIR/$font_name" "$font_url"
    log_info "$font_name installed successfully"
}

# Install font on Linux
install_linux_font() {
    local font_url="$1"
    local font_name="$2"
    
    if [ -f "$FONT_DIR/$font_name" ]; then
        log_info "$font_name already installed"
        return 0
    fi
    
    log_info "Installing $font_name..."
    curl -fLo "$FONT_DIR/$font_name" "$font_url"
    log_info "$font_name installed successfully"
}

# Main installation function
install_fonts() {
    detect_os
    
    log_info "Installing Nerd Fonts for GoodTerminal..."
    log_info "Font directory: $FONT_DIR"
    
    # CascadiaCode Nerd Font (VSCode default)
    local cascadia_base="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1"
    
    if [[ "$OS" == "macos" ]]; then
        # Download and extract the zip file
        if [ ! -f "$FONT_DIR/CascadiaCodeNerdFont-Regular.ttf" ]; then
            log_info "Downloading CascadiaCode Nerd Font..."
            curl -fLo "$FONT_DIR/CascadiaCode.zip" "$cascadia_base/CascadiaCode.zip"
            
            cd "$FONT_DIR"
            log_info "Extracting font files..."
            unzip -o CascadiaCode.zip "*.ttf"
            rm CascadiaCode.zip
            log_info "CascadiaCode Nerd Font installed successfully"
        else
            log_info "CascadiaCode Nerd Font already installed"
        fi
    else
        # Linux - install individual font files
        install_linux_font "$cascadia_base/CascadiaCode/CascadiaCodeNerdFont-Regular.ttf" "CascadiaCodeNerdFont-Regular.ttf"
        install_linux_font "$cascadia_base/CascadiaCode/CascadiaCodeNerdFont-Bold.ttf" "CascadiaCodeNerdFont-Bold.ttf"
        install_linux_font "$cascadia_base/CascadiaCode/CascadiaCodeNerdFont-Italic.ttf" "CascadiaCodeNerdFont-Italic.ttf"
        install_linux_font "$cascadia_base/CascadiaCode/CascadiaCodeNerdFont-BoldItalic.ttf" "CascadiaCodeNerdFont-BoldItalic.ttf"
        
        # Refresh font cache on Linux
        if command -v fc-cache &> /dev/null; then
            log_info "Refreshing font cache..."
            fc-cache -fv
        fi
    fi
    
    log_info "Font installation completed!"
    
    if [[ "$OS" == "macos" ]]; then
        log_info "Font installed to: $FONT_DIR"
        log_info "You may need to restart applications to see the new font."
        log_info ""
        log_info "To configure iTerm2:"
        log_info "1. Open iTerm2 Preferences (⌘,)"
        log_info "2. Go to Profiles → Text"
        log_info "3. Click 'Change Font' and select 'CaskaydiaCove Nerd Font'"
        log_info "4. Set size to 14 for VSCode consistency"
        log_info ""
        log_info "Or import the preconfigured profile:"
        log_info "• Profiles → Import JSON → config/iterm2/GoodTerminal-VSCode-Profile.json"
    else
        log_info "Font installed to: $FONT_DIR"
        log_info "Configure your terminal to use 'CascadiaCode Nerd Font' size 14"
    fi
}

# Run installation
install_fonts