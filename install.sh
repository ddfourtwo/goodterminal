#!/bin/bash

# GoodTerminal Install/Update Script
# This script installs or updates mosh, tmux, nvim and their configurations

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_prompt() {
    echo -e "${BLUE}[?]${NC} $1"
}

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            OS="debian"
            PKG_MANAGER="apt-get"
            PKG_UPDATE="apt-get update"
            PKG_INSTALL="apt-get install -y"
        elif command -v yum &> /dev/null; then
            OS="rhel"
            PKG_MANAGER="yum"
            PKG_UPDATE="yum check-update || true"
            PKG_INSTALL="yum install -y"
        elif command -v pacman &> /dev/null; then
            OS="arch"
            PKG_MANAGER="pacman"
            PKG_UPDATE="pacman -Sy"
            PKG_INSTALL="pacman -S --noconfirm"
        else
            log_error "Unsupported Linux distribution"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PKG_MANAGER="brew"
        PKG_UPDATE="brew update"
        PKG_INSTALL="brew install"
    else
        log_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
    
    log_info "Detected OS: $OS"
}

# Check if running as root (not recommended)
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_warning "This script is running as root. It's recommended to run as a normal user with sudo privileges."
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Install package managers if missing
install_package_managers() {
    if [[ "$OS" == "macos" ]]; then
        if ! command -v brew &> /dev/null; then
            log_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
    fi
}

# Install dependencies
install_dependencies() {
    log_info "Installing dependencies..."
    
    # Common dependencies
    local deps="curl git wget build-essential"
    
    if [[ "$OS" == "debian" ]]; then
        sudo $PKG_UPDATE
        sudo $PKG_INSTALL $deps software-properties-common zsh
    elif [[ "$OS" == "rhel" ]]; then
        sudo $PKG_UPDATE
        sudo $PKG_INSTALL $deps zsh
    elif [[ "$OS" == "arch" ]]; then
        sudo $PKG_UPDATE
        sudo $PKG_INSTALL base-devel git curl wget zsh
    elif [[ "$OS" == "macos" ]]; then
        $PKG_UPDATE
        $PKG_INSTALL git curl wget zsh
    fi
}

# Install mosh
install_mosh() {
    log_info "Installing mosh..."
    
    if [[ "$OS" == "debian" ]] || [[ "$OS" == "rhel" ]] || [[ "$OS" == "arch" ]]; then
        sudo $PKG_INSTALL mosh
    elif [[ "$OS" == "macos" ]]; then
        $PKG_INSTALL mosh
    fi
    
    log_info "Mosh installed: $(mosh --version | head -n1)"
}

# Install tmux
install_tmux() {
    log_info "Installing tmux..."
    
    if [[ "$OS" == "debian" ]]; then
        # Install latest tmux from source on Debian/Ubuntu
        sudo $PKG_INSTALL libevent-dev ncurses-dev build-essential bison pkg-config automake
        
        TMUX_VERSION="3.4"
        cd /tmp
        wget https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
        tar -xzf tmux-${TMUX_VERSION}.tar.gz
        cd tmux-${TMUX_VERSION}
        ./configure && make
        sudo make install
        cd ~
    elif [[ "$OS" == "rhel" ]]; then
        sudo $PKG_INSTALL tmux
    elif [[ "$OS" == "arch" ]]; then
        sudo $PKG_INSTALL tmux
    elif [[ "$OS" == "macos" ]]; then
        $PKG_INSTALL tmux
    fi
    
    # Install TPM (Tmux Plugin Manager)
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        log_info "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
    
    log_info "Tmux installed: $(tmux -V)"
}

# Install Neovim
install_nvim() {
    log_info "Installing Neovim..."
    
    if [[ "$OS" == "debian" ]]; then
        # Install latest neovim from official repository
        sudo add-apt-repository ppa:neovim-ppa/unstable -y
        sudo apt-get update
        sudo $PKG_INSTALL neovim
    elif [[ "$OS" == "rhel" ]]; then
        # Install from EPEL
        sudo yum install -y epel-release
        sudo $PKG_INSTALL neovim
    elif [[ "$OS" == "arch" ]]; then
        sudo $PKG_INSTALL neovim
    elif [[ "$OS" == "macos" ]]; then
        $PKG_INSTALL neovim
    fi
    
    # Install additional tools for Neovim
    log_info "Installing Neovim dependencies..."
    
    # Ensure curl is available (needed for Windsurf)
    if ! command -v curl &> /dev/null; then
        log_info "Installing curl..."
        sudo $PKG_INSTALL curl
    fi
    
    # Node.js for LSP servers and CLI tools
    if ! command -v node &> /dev/null; then
        log_info "Installing Node.js..."
        if [[ "$OS" == "debian" ]]; then
            curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
            sudo $PKG_INSTALL nodejs
        elif [[ "$OS" == "rhel" ]]; then
            curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
            sudo $PKG_INSTALL nodejs
        elif [[ "$OS" == "arch" ]]; then
            sudo $PKG_INSTALL nodejs npm
        elif [[ "$OS" == "macos" ]]; then
            $PKG_INSTALL node
        fi
    fi
    
    # Install Claude Code CLI
    if ! command -v claude &> /dev/null; then
        log_info "Installing Claude Code CLI..."
        npm install -g @anthropic-ai/claude-code
        
        # Check if npm bin is in PATH
        NPM_BIN=$(npm bin -g)
        if [[ ":$PATH:" != *":$NPM_BIN:"* ]]; then
            log_warning "NPM global bin directory not in PATH. Adding to shell profile..."
            echo "export PATH=\"$NPM_BIN:\$PATH\"" >> "$SHELL_PROFILE"
        fi
    fi
    
    # Python for LSP and other tools
    if ! command -v python3 &> /dev/null; then
        log_info "Installing Python..."
        sudo $PKG_INSTALL python3 python3-pip
    fi
    
    # Ripgrep for better searching
    if ! command -v rg &> /dev/null; then
        log_info "Installing ripgrep..."
        if [[ "$OS" == "debian" ]] || [[ "$OS" == "rhel" ]] || [[ "$OS" == "arch" ]]; then
            sudo $PKG_INSTALL ripgrep
        elif [[ "$OS" == "macos" ]]; then
            $PKG_INSTALL ripgrep
        fi
    fi
    
    # Lazygit for visual git management
    if ! command -v lazygit &> /dev/null; then
        log_info "Installing lazygit..."
        if [[ "$OS" == "debian" ]]; then
            # Add lazygit repo and install
            sudo add-apt-repository ppa:lazygit-team/release -y
            sudo apt-get update
            sudo apt-get install lazygit -y
        elif [[ "$OS" == "rhel" ]]; then
            # Install from copr
            sudo dnf copr enable atim/lazygit -y
            sudo dnf install lazygit -y
        elif [[ "$OS" == "arch" ]]; then
            sudo $PKG_INSTALL lazygit
        elif [[ "$OS" == "macos" ]]; then
            $PKG_INSTALL lazygit
        fi
    fi
    
    log_info "Neovim installed: $(nvim --version | head -n1)"
}

# Configure installations
configure_installations() {
    log_info "Configuring installations..."
    
    # Backup existing configurations
    backup_config() {
        local config_path=$1
        if [ -e "$config_path" ]; then
            log_info "Backing up existing $config_path to ${config_path}.bak"
            mv "$config_path" "${config_path}.bak"
        fi
    }
    
    # Neovim configuration
    log_info "Setting up Neovim configuration..."
    if [ ! -L "$HOME/.config/nvim" ]; then
        backup_config "$HOME/.config/nvim"
    fi
    mkdir -p "$HOME/.config"
    ln -sf "$SCRIPT_DIR/config/nvim" "$HOME/.config/nvim"
    
    # Tmux configuration
    log_info "Setting up tmux configuration..."
    if [ ! -L "$HOME/.tmux.conf" ]; then
        backup_config "$HOME/.tmux.conf"
    fi
    ln -sf "$SCRIPT_DIR/config/tmux/tmux.conf" "$HOME/.tmux.conf"
    
    # Shell configuration (source in shell profile)
    log_info "Setting up shell configuration..."
    
    # Determine shell profile file
    SHELL_PROFILE=""
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_PROFILE="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_PROFILE="$HOME/.bashrc"
    else
        SHELL_PROFILE="$HOME/.profile"
    fi
    
    # Add shell configuration sourcing if not already present
    if ! grep -q "goodterminal/config/shell/config" "$SHELL_PROFILE"; then
        log_info "Adding shell configuration to $SHELL_PROFILE"
        echo "" >> "$SHELL_PROFILE"
        echo "# GoodTerminal shell configuration" >> "$SHELL_PROFILE"
        echo "[ -f \"$SCRIPT_DIR/config/shell/config\" ] && source \"$SCRIPT_DIR/config/shell/config\"" >> "$SHELL_PROFILE"
    fi
    
    # Add mosh configuration sourcing if not already present
    if ! grep -q "goodterminal/config/mosh/config" "$SHELL_PROFILE"; then
        log_info "Adding mosh configuration to $SHELL_PROFILE"
        echo "" >> "$SHELL_PROFILE"
        echo "# GoodTerminal mosh configuration" >> "$SHELL_PROFILE"
        echo "[ -f \"$SCRIPT_DIR/config/mosh/config\" ] && source \"$SCRIPT_DIR/config/mosh/config\"" >> "$SHELL_PROFILE"
    fi
    
    # Optionally set zsh as default shell
    if command -v zsh &> /dev/null; then
        CURRENT_SHELL=$(basename "$SHELL")
        if [ "$CURRENT_SHELL" != "zsh" ]; then
            log_prompt "Would you like to set zsh as your default shell? (y/N) "
            read -r SET_ZSH
            if [[ $SET_ZSH =~ ^[Yy]$ ]]; then
                log_info "Setting zsh as default shell..."
                if command -v chsh &> /dev/null; then
                    chsh -s $(which zsh)
                    log_info "Default shell changed to zsh. Please log out and back in for changes to take effect."
                else
                    log_warning "chsh not available. Please manually change your shell with: chsh -s $(which zsh)"
                fi
            fi
        else
            log_info "zsh is already your default shell"
        fi
    fi
}

# Update plugins
update_plugins() {
    log_info "Updating plugins..."
    
    # Update tmux plugins
    log_info "Updating tmux plugins..."
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        # Update TPM itself
        cd "$HOME/.tmux/plugins/tpm" && git pull
        
        tmux start-server
        tmux new-session -d -s temp_install
        
        # Install/update plugins using TPM
        log_info "Installing/updating tmux plugins via TPM..."
        tmux run-shell "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"
        tmux run-shell "$HOME/.tmux/plugins/tpm/scripts/update_plugin.sh all"
        
        # Source the config to make sure plugins are loaded
        tmux source-file "$HOME/.tmux.conf"
        
        tmux kill-session -t temp_install
    else
        log_error "TPM not found. Please restart tmux and press prefix + I to install plugins."
    fi
    
    # Update Neovim plugins
    log_info "Updating Neovim plugins (this may take a moment)..."
    
    # Update/install plugins via Lazy.nvim without Windsurf auth
    SKIP_WINDSURF_AUTH=1 nvim --headless "+Lazy! sync" +qa
    
    # Update TreeSitter parsers
    log_info "Updating TreeSitter parsers..."
    SKIP_WINDSURF_AUTH=1 nvim --headless "+TSUpdateSync" +qa
    
    # Update/install LSP servers via Mason
    log_info "Updating LSP servers..."
    SKIP_WINDSURF_AUTH=1 nvim --headless "+MasonInstall lua-language-server pyright typescript-language-server bash-language-server" +qa
    SKIP_WINDSURF_AUTH=1 nvim --headless "+MasonUpdate" +qa
    
    log_info "Plugin updates completed!"
}

# Update git repository
update_repo() {
    log_info "Updating GoodTerminal repository..."
    cd "$SCRIPT_DIR"
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        log_warning "You have uncommitted changes. Stashing them..."
        git stash
        STASHED=true
    fi
    
    # Pull latest changes
    git pull origin main || git pull origin master || git pull
    
    # Restore stashed changes if any
    if [ "$STASHED" = true ]; then
        log_info "Restoring stashed changes..."
        git stash pop
    fi
}

# Check health
check_health() {
    log_info "Running health checks..."
    
    # Check tmux
    if command -v tmux &> /dev/null; then
        log_info "Tmux version: $(tmux -V)"
    else
        log_warning "Tmux not found"
    fi
    
    # Check nvim
    if command -v nvim &> /dev/null; then
        log_info "Neovim version: $(nvim --version | head -n1)"
    else
        log_warning "Neovim not found"
    fi
    
    # Check mosh
    if command -v mosh &> /dev/null; then
        log_info "Mosh version: $(mosh --version | head -n1)"
    else
        log_warning "Mosh not found"
    fi
    
    # Check lazygit
    if command -v lazygit &> /dev/null; then
        log_info "Lazygit version: $(lazygit --version | head -n1)"
    else
        log_warning "Lazygit not found"
    fi
    
    # Check Claude Code
    if command -v claude &> /dev/null; then
        log_info "Claude Code version: $(claude --version)"
    else
        log_warning "Claude Code not found"
    fi
    
    # AI tools reminder
    log_info ""
    log_info "AI Tools setup:"
    log_info "- For AI autocompletion in nvim: run :Codeium Auth"
    log_info "- For Claude Code CLI: run 'claude auth' to authenticate"
}

# Full installation
full_install() {
    log_info "Starting full GoodTerminal installation..."
    
    detect_os
    install_package_managers
    install_dependencies
    install_mosh
    install_tmux
    install_nvim
    configure_installations
    update_plugins
    check_health
    
    log_info "GoodTerminal installation completed successfully!"
    log_info "Please restart your shell or run 'source $SHELL_PROFILE' to apply configurations."
    log_info "For tmux, you may need to press prefix + I (Ctrl-a + I) to install plugins on first run."
    log_info ""
    log_info "IMPORTANT - AI Tools Setup:"
    log_info "1. For AI autocompletion in Neovim:"
    log_info "   - Open neovim and run :Codeium Auth"
    log_info "   - Follow the instructions to authenticate with Codeium"
    log_info ""
    log_info "2. For Claude Code CLI:"
    log_info "   - Run 'claude auth' to authenticate"
    log_info "   - Use 'claude help' to see available commands"
}

# Update only
update_only() {
    log_info "Updating GoodTerminal..."
    
    update_repo
    configure_installations
    update_plugins
    check_health
    
    log_info "GoodTerminal update completed successfully!"
    log_info "Restart your terminal or tmux session to apply all changes."
}

# Update packages
update_packages() {
    log_info "Checking for package updates..."
    detect_os
    
    if [[ "$OS" == "debian" ]]; then
        sudo apt-get update
        log_info "Updating packages on Debian/Ubuntu..."
        sudo apt-get upgrade -y neovim tmux mosh
    elif [[ "$OS" == "rhel" ]]; then
        sudo yum check-update
        log_info "Updating packages on RHEL/CentOS..."
        sudo yum update -y neovim tmux mosh
    elif [[ "$OS" == "arch" ]]; then
        sudo pacman -Sy
        log_info "Updating packages on Arch..."
        sudo pacman -Syu --noconfirm neovim tmux mosh
    elif [[ "$OS" == "macos" ]]; then
        brew update
        log_info "Updating packages on macOS..."
        brew upgrade neovim tmux mosh
    fi
}

# Purge and clean installation
purge_and_reinstall() {
    log_warning "This will remove all GoodTerminal configurations and plugins!"
    log_prompt "Are you sure you want to continue? (y/N) "
    read -r REPLY
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Purge cancelled"
        return
    fi
    
    log_info "Starting purge and clean reinstall..."
    
    # Remove all tmux plugins
    log_info "Removing tmux plugins..."
    rm -rf ~/.tmux/plugins/*
    
    # Remove neovim plugins and cache
    log_info "Removing neovim plugins and cache..."
    rm -rf ~/.local/share/nvim
    rm -rf ~/.cache/nvim
    rm -rf ~/.config/nvim/lazy-lock.json
    
    # Remove symbolic links
    log_info "Removing configuration links..."
    rm -f ~/.tmux.conf
    rm -f ~/.config/nvim
    
    # Remove shell configuration entries
    log_info "Cleaning shell profile..."
    if [ -f "$HOME/.zshrc" ]; then
        sed -i.bak '/# GoodTerminal shell configuration/,+2d' "$HOME/.zshrc"
        sed -i.bak '/# GoodTerminal mosh configuration/,+2d' "$HOME/.zshrc"
    fi
    if [ -f "$HOME/.bashrc" ]; then
        sed -i.bak '/# GoodTerminal shell configuration/,+2d' "$HOME/.bashrc"
        sed -i.bak '/# GoodTerminal mosh configuration/,+2d' "$HOME/.bashrc"
    fi
    
    log_info "Purge complete. Starting fresh installation..."
    
    # Run full installation
    full_install
}

# Main menu
show_menu() {
    echo -e "\n${BLUE}GoodTerminal Install/Update Script${NC}"
    echo -e "${BLUE}=================================${NC}\n"
    echo "1) Full installation (first time setup)"
    echo "2) Update configurations and plugins"
    echo "3) Update system packages only (mosh, tmux, nvim)"
    echo "4) Update everything (configs, plugins, and packages)"
    echo "5) Check health status"
    echo "6) Purge and reinstall (clean slate)"
    echo "7) Exit"
    echo
    log_prompt "Select an option (1-7): "
}

# Main function
main() {
    check_root
    
    # If no arguments, show menu
    if [ $# -eq 0 ]; then
        while true; do
            show_menu
            read -r choice
            
            case $choice in
                1)
                    full_install
                    break
                    ;;
                2)
                    update_only
                    break
                    ;;
                3)
                    update_packages
                    break
                    ;;
                4)
                    update_repo
                    update_packages
                    configure_installations
                    update_plugins
                    check_health
                    log_info "Full update completed!"
                    break
                    ;;
                5)
                    check_health
                    ;;
                6)
                    purge_and_reinstall
                    break
                    ;;
                7)
                    log_info "Exiting..."
                    exit 0
                    ;;
                *)
                    log_error "Invalid option. Please select 1-7."
                    ;;
            esac
        done
    else
        # Handle command line arguments for automation
        case "$1" in
            --install|-i)
                full_install
                ;;
            --update|-u)
                update_only
                ;;
            --update-packages|-p)
                update_packages
                ;;
            --update-all|-a)
                update_repo
                update_packages
                configure_installations
                update_plugins
                check_health
                ;;
            --health|-h)
                check_health
                ;;
            --purge)
                purge_and_reinstall
                ;;
            *)
                echo "Usage: $0 [option]"
                echo "Options:"
                echo "  --install, -i        Full installation"
                echo "  --update, -u         Update configurations and plugins"
                echo "  --update-packages, -p Update system packages only"
                echo "  --update-all, -a     Update everything"
                echo "  --health, -h         Check health status"
                echo "  --purge              Purge and reinstall (clean slate)"
                echo
                echo "Or run without arguments for interactive menu"
                exit 1
                ;;
        esac
    fi
}

# Run main function
main "$@"