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

# Source nvm if available to ensure proper Node.js environment
if [ -n "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
    \. "$NVM_DIR/nvm.sh"
elif [ -s "$HOME/.nvm/nvm.sh" ]; then
    export NVM_DIR="$HOME/.nvm"
    \. "$NVM_DIR/nvm.sh"
fi

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

# Wait for apt lock to be released
wait_for_apt() {
    local max_wait=300  # 5 minutes
    local wait_time=0
    
    while true; do
        # Check for all possible apt locks
        if ! fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 && \
           ! fuser /var/lib/dpkg/lock >/dev/null 2>&1 && \
           ! fuser /var/cache/apt/archives/lock >/dev/null 2>&1 && \
           ! fuser /var/lib/apt/lists/lock >/dev/null 2>&1; then
            # No locks detected, we can proceed
            return 0
        fi
        
        if [ $wait_time -ge $max_wait ]; then
            log_error "Apt lock not released after $max_wait seconds"
            # Show which processes are holding the locks
            log_info "Processes holding apt locks:"
            fuser -v /var/lib/dpkg/lock-frontend 2>&1 || true
            fuser -v /var/lib/dpkg/lock 2>&1 || true
            return 1
        fi
        
        log_info "Waiting for apt lock to be released... ($wait_time/$max_wait seconds)"
        sleep 5
        wait_time=$((wait_time + 5))
    done
}

# Run apt command with lock waiting
run_apt_command() {
    local cmd="$1"
    shift
    local args="$@"
    
    # Disable exit on error temporarily
    local old_e
    [[ $- == *e* ]] && old_e=1 || old_e=0
    set +e
    
    # Try the command first  
    $cmd $args 2>&1 | tee /tmp/apt_output.tmp
    local result=${PIPESTATUS[0]}
    
    # Check if the error was due to lock
    if [ $result -ne 0 ] && grep -q "Could not get lock\|dpkg frontend lock" /tmp/apt_output.tmp; then
        log_info "APT lock detected, waiting for it to be released..."
        wait_for_apt
        # Try again after waiting
        $cmd $args
        result=$?
    fi
    
    # Clean up temp file
    rm -f /tmp/apt_output.tmp
    
    # Re-enable exit on error if it was enabled
    [ $old_e -eq 1 ] && set -e
    
    return $result
}

# Install dependencies
install_dependencies() {
    log_info "Installing dependencies..."
    
    # Common dependencies
    local deps="curl git wget build-essential"
    
    if [[ "$OS" == "debian" ]]; then
        run_apt_command sudo $PKG_UPDATE
        run_apt_command sudo $PKG_INSTALL $deps software-properties-common zsh fzf
    elif [[ "$OS" == "rhel" ]]; then
        sudo $PKG_UPDATE
        sudo $PKG_INSTALL $deps zsh fzf
    elif [[ "$OS" == "arch" ]]; then
        sudo $PKG_UPDATE
        sudo $PKG_INSTALL base-devel git curl wget zsh fzf
    elif [[ "$OS" == "macos" ]]; then
        $PKG_UPDATE
        $PKG_INSTALL git curl wget zsh fzf
    fi
    
    # Install fzf shell integration
    install_fzf_integration
    
    # Install Rust/Cargo if not already installed
    install_rust
    
    # Install TWM (Tmux Workspace Manager)
    install_twm
}

# Install mosh
install_mosh() {
    log_info "Installing mosh..."
    
    if [[ "$OS" == "debian" ]]; then
        run_apt_command sudo $PKG_INSTALL mosh
    elif [[ "$OS" == "rhel" ]] || [[ "$OS" == "arch" ]]; then
        sudo $PKG_INSTALL mosh
    elif [[ "$OS" == "macos" ]]; then
        $PKG_INSTALL mosh
    fi
    
    log_info "Mosh installed: $(mosh --version | head -n1)"
}

# Install fzf shell integration
install_fzf_integration() {
    log_info "Installing fzf shell integration..."
    
    if command -v fzf &> /dev/null; then
        # For macOS with homebrew
        if [[ "$OS" == "macos" ]]; then
            FZF_PATH="$(brew --prefix)/opt/fzf"
            if [ -d "$FZF_PATH" ] && [ -f "$FZF_PATH/install" ]; then
                log_info "Running fzf install script..."
                "$FZF_PATH/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
            fi
        else
            # For Linux distributions
            if command -v dpkg &> /dev/null; then
                # Debian/Ubuntu
                FZF_PATH="/usr/share/doc/fzf/examples"
                if [ -d "$FZF_PATH" ]; then
                    [ -f "$FZF_PATH/key-bindings.zsh" ] && cp "$FZF_PATH/key-bindings.zsh" ~/.fzf.key-bindings.zsh
                    [ -f "$FZF_PATH/completion.zsh" ] && cp "$FZF_PATH/completion.zsh" ~/.fzf.completion.zsh
                    # Create ~/.fzf.zsh to source these files
                    echo '[ -f ~/.fzf.key-bindings.zsh ] && source ~/.fzf.key-bindings.zsh' > ~/.fzf.zsh
                    echo '[ -f ~/.fzf.completion.zsh ] && source ~/.fzf.completion.zsh' >> ~/.fzf.zsh
                fi
            fi
        fi
    else
        log_warning "fzf not found. Install fzf and re-run the script."
    fi
}

# Check and install clipboard utilities
check_and_install_clipboard_utils() {
    log_info "Checking for clipboard utilities..."
    
    local clipboard_found=false
    if command -v xclip &> /dev/null || command -v xsel &> /dev/null || command -v wl-copy &> /dev/null; then
        clipboard_found=true
    fi
    
    if [[ "$OSTYPE" == "darwin"* ]] && command -v pbcopy &> /dev/null; then
        clipboard_found=true
    fi
    
    if [ "$clipboard_found" = false ]; then
        log_info "Installing missing clipboard utilities for tmux-yank..."
        if [[ "$OS" == "debian" ]]; then
            # Install xclip for X11 clipboard support
            run_apt_command sudo $PKG_INSTALL xclip
            # Also install wl-clipboard for Wayland support
            run_apt_command sudo $PKG_INSTALL wl-clipboard
        elif [[ "$OS" == "rhel" ]]; then
            sudo $PKG_INSTALL xclip
            # Try to install wl-clipboard if available
            sudo $PKG_INSTALL wl-clipboard || log_warning "wl-clipboard not available in repos"
        elif [[ "$OS" == "arch" ]]; then
            sudo $PKG_INSTALL xclip wl-clipboard
        elif [[ "$OS" == "macos" ]]; then
            # macOS has pbcopy/pbpaste built-in, but install reattach-to-user-namespace for older versions
            $PKG_INSTALL reattach-to-user-namespace || true
        fi
    else
        log_info "Clipboard utilities already installed"
    fi
}

# Install tmux
install_tmux() {
    log_info "Installing tmux..."
    
    if [[ "$OS" == "debian" ]]; then
        # Install latest tmux from source on Debian/Ubuntu
        run_apt_command sudo $PKG_INSTALL libevent-dev ncurses-dev build-essential bison pkg-config automake
        
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
    
    # Install clipboard utilities for tmux-yank
    check_and_install_clipboard_utils
    
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
        run_apt_command sudo apt-get update
        run_apt_command sudo $PKG_INSTALL neovim
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
        if [[ "$OS" == "debian" ]]; then
            run_apt_command sudo $PKG_INSTALL curl
        else
            sudo $PKG_INSTALL curl
        fi
    fi
    
    # Node.js for LSP servers and CLI tools
    if ! command -v node &> /dev/null; then
        # Check if nvm is installed
        if [ -n "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
            log_info "nvm detected. Using nvm to install Node.js..."
            # Source nvm if not already sourced
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            nvm install --lts
            nvm use --lts
            log_info "Node.js installed via nvm: $(node --version)"
        else
            log_info "Installing Node.js..."
            log_warning "Consider using nvm for better Node version management"
            if [[ "$OS" == "debian" ]]; then
                curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
                run_apt_command sudo $PKG_INSTALL nodejs
            elif [[ "$OS" == "rhel" ]]; then
                curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
                sudo $PKG_INSTALL nodejs
            elif [[ "$OS" == "arch" ]]; then
                sudo $PKG_INSTALL nodejs npm
            elif [[ "$OS" == "macos" ]]; then
                $PKG_INSTALL node
            fi
        fi
    else
        log_info "Node.js already installed: $(node --version)"
    fi
    
    # Install Claude Code CLI
    if ! command -v claude &> /dev/null; then
        log_info "Installing Claude Code CLI..."
        
        # Check if we're using nvm and ensure correct npm is used
        if [ -n "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            log_info "Using npm from nvm: $(which npm)"
        fi
        
        npm install -g @anthropic-ai/claude-code
        
        # Check if npm bin is in PATH
        NPM_BIN=$(npm bin -g)
        if [[ ":$PATH:" != *":$NPM_BIN:"* ]]; then
            log_warning "NPM global bin directory not in PATH. Adding to shell profile..."
            # Determine the shell profile file
            if [ -f "$HOME/.zshrc" ]; then
                echo "export PATH=\"$NPM_BIN:\$PATH\"" >> "$HOME/.zshrc"
            elif [ -f "$HOME/.bashrc" ]; then
                echo "export PATH=\"$NPM_BIN:\$PATH\"" >> "$HOME/.bashrc"
            fi
        fi
    fi
    
    # Python for LSP and other tools
    if ! command -v python3 &> /dev/null; then
        log_info "Installing Python..."
        if [[ "$OS" == "debian" ]]; then
            run_apt_command sudo $PKG_INSTALL python3 python3-pip
        else
            sudo $PKG_INSTALL python3 python3-pip
        fi
    fi
    
    # Ripgrep for better searching
    if ! command -v rg &> /dev/null; then
        log_info "Installing ripgrep..."
        if [[ "$OS" == "debian" ]]; then
            run_apt_command sudo $PKG_INSTALL ripgrep
        elif [[ "$OS" == "rhel" ]] || [[ "$OS" == "arch" ]]; then
            sudo $PKG_INSTALL ripgrep
        elif [[ "$OS" == "macos" ]]; then
            $PKG_INSTALL ripgrep
        fi
    fi
    
    # Lazygit for visual git management
    if ! command -v lazygit &> /dev/null; then
        log_info "Installing lazygit..."
        if [[ "$OS" == "debian" ]]; then
            # For Ubuntu 22.04+ and Debian, install from GitHub releases
            LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]+' || echo "0.44.1")
            
            cd /tmp
            wget "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
            tar xf "lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" lazygit
            sudo install lazygit /usr/local/bin
            cd -
            rm -f /tmp/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz /tmp/lazygit
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

# Install Rust and Cargo
install_rust() {
    if ! command -v cargo &> /dev/null; then
        log_info "Installing Rust and Cargo..."
        
        if [[ "$OS" == "debian" ]] || [[ "$OS" == "rhel" ]] || [[ "$OS" == "arch" ]]; then
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
        elif [[ "$OS" == "macos" ]]; then
            $PKG_INSTALL rustup-init
            rustup-init -y
            source "$HOME/.cargo/env"
        fi
        
        log_info "Rust installed: $(rustc --version)"
    else
        log_info "Rust already installed: $(rustc --version)"
    fi
}

# Install TWM (Tmux Workspace Manager)
install_twm() {
    log_info "Installing TWM (Tmux Workspace Manager)..."
    
    # Ensure Rust/Cargo is in PATH
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi
    
    if ! command -v twm &> /dev/null; then
        if command -v cargo &> /dev/null; then
            log_info "Installing TWM via cargo..."
            cargo install twm
            log_info "TWM installed: $(twm --version 2>&1 | head -n1)"
        else
            log_warning "Cargo not found. Cannot install TWM."
        fi
    else
        log_info "TWM already installed: $(twm --version 2>&1 | head -n1)"
    fi
    
    # Create TWM configuration directory
    mkdir -p "$HOME/.config/twm"
    
    # Link TWM configuration
    if [ ! -f "$HOME/.config/twm/twm.yaml" ]; then
        log_info "Setting up TWM configuration..."
        ln -sf "$SCRIPT_DIR/config/twm/twm.yaml" "$HOME/.config/twm/twm.yaml"
    fi
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
    
    # Shell configuration with oh-my-zsh
    log_info "Setting up shell configuration with oh-my-zsh..."
    
    # Install oh-my-zsh if not already installed
    if command -v zsh &> /dev/null; then
        if [ ! -d "$HOME/.oh-my-zsh" ]; then
            log_info "Installing oh-my-zsh..."
            sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        fi
        
        # Install additional plugins
        log_info "Installing oh-my-zsh plugins..."
        
        # Set ZSH_CUSTOM if not set
        ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
        
        # zsh-autosuggestions
        AUTOSUGGESTIONS_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        if [ ! -d "$AUTOSUGGESTIONS_DIR" ]; then
            log_info "Installing zsh-autosuggestions..."
            git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"
        else
            log_info "zsh-autosuggestions already installed"
        fi
        
        # zsh-syntax-highlighting
        SYNTAX_HIGHLIGHTING_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        if [ ! -d "$SYNTAX_HIGHLIGHTING_DIR" ]; then
            log_info "Installing zsh-syntax-highlighting..."
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_HIGHLIGHTING_DIR"
        else
            log_info "zsh-syntax-highlighting already installed"
        fi
        
        # zsh-autocomplete
        AUTOCOMPLETE_DIR="$ZSH_CUSTOM/plugins/zsh-autocomplete"
        if [ ! -d "$AUTOCOMPLETE_DIR" ]; then
            log_info "Installing zsh-autocomplete..."
            git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git "$AUTOCOMPLETE_DIR"
        else
            log_info "zsh-autocomplete already installed"
        fi
        
        # Configure oh-my-zsh settings
        if [ -f "$HOME/.zshrc" ]; then
            log_info "Integrating GoodTerminal settings into existing .zshrc..."
            
            # Check if our configuration is already present by looking for the actual source command
            if ! grep -q "goodterminal/config/shell/config" "$HOME/.zshrc"; then
                # Backup existing .zshrc
                cp "$HOME/.zshrc" "$HOME/.zshrc.backup-$(date +%Y%m%d-%H%M%S)"
                
                # Add our plugins to the existing plugins list
                if grep -q "^plugins=" "$HOME/.zshrc"; then
                    # Extract existing plugins - get the current plugins line and clean it up
                    existing_plugins=$(grep "^plugins=" "$HOME/.zshrc" | sed 's/plugins=(//' | sed 's/)//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    log_info "Current plugins: $existing_plugins"
                    
                    # Add our required plugins
                    our_plugins="zsh-autosuggestions zsh-syntax-highlighting zsh-autocomplete"
                    for plugin in $our_plugins; do
                        if ! echo "$existing_plugins" | grep -q "$plugin"; then
                            existing_plugins="$existing_plugins $plugin"
                        fi
                    done
                    
                    # Update the plugins line - use sed with proper escaping
                    sed -i.tmp "s/^plugins=(.*)$/plugins=($existing_plugins)/" "$HOME/.zshrc"
                    rm -f "$HOME/.zshrc.tmp"
                else
                    # Add plugins line if it doesn't exist
                    echo "" >> "$HOME/.zshrc"
                    echo "# Plugins" >> "$HOME/.zshrc"
                    echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-autocomplete)" >> "$HOME/.zshrc"
                fi
                
                # Add our configuration block
                echo "" >> "$HOME/.zshrc"
                echo "# GoodTerminal configuration" >> "$HOME/.zshrc"
                echo "# Plugin configuration" >> "$HOME/.zshrc"
                echo "export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'" >> "$HOME/.zshrc"
                echo "export ZSH_AUTOSUGGEST_STRATEGY=(history completion)" >> "$HOME/.zshrc"
                echo "" >> "$HOME/.zshrc"
                echo "# Key bindings" >> "$HOME/.zshrc"
                echo "bindkey '^[[1;5D' backward-word       # Ctrl+Left" >> "$HOME/.zshrc"
                echo "bindkey '^[[1;5C' autosuggest-accept  # Ctrl+Right to accept" >> "$HOME/.zshrc"
                echo "bindkey '^[f' autosuggest-accept      # Alt+f to accept" >> "$HOME/.zshrc"
                echo "" >> "$HOME/.zshrc"
                echo "# Load GoodTerminal configurations" >> "$HOME/.zshrc"
                echo "[ -f \"$SCRIPT_DIR/config/shell/config\" ] && source \"$SCRIPT_DIR/config/shell/config\"" >> "$HOME/.zshrc"
                echo "[ -f \"$SCRIPT_DIR/config/mosh/config\" ] && source \"$SCRIPT_DIR/config/mosh/config\"" >> "$HOME/.zshrc"
                echo "" >> "$HOME/.zshrc"
                echo "# Load fzf configuration" >> "$HOME/.zshrc"
                echo "[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh" >> "$HOME/.zshrc"
                
                log_info "Added GoodTerminal configuration to existing .zshrc"
            else
                log_info "GoodTerminal configuration already present in .zshrc"
            fi
        else
            # No existing .zshrc, create from our template
            log_info "Creating new .zshrc with GoodTerminal settings..."
            sed "s|__SCRIPT_DIR__|$SCRIPT_DIR|g" "$SCRIPT_DIR/config/shell/zshrc.template" > "$HOME/.zshrc"
        fi
    fi
    
    # For bash users, add basic configuration
    if [ -f "$HOME/.bashrc" ]; then
        SHELL_PROFILE="$HOME/.bashrc"
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
    
    # Update oh-my-zsh and plugins
    if command -v zsh &> /dev/null && [ -d "$HOME/.oh-my-zsh" ]; then
        log_info "Updating oh-my-zsh and plugins..."
        
        # Update oh-my-zsh using the upgrade script
        if [ -f "$HOME/.oh-my-zsh/tools/upgrade.sh" ]; then
            log_info "Running oh-my-zsh upgrade..."
            ZSH="$HOME/.oh-my-zsh" zsh "$HOME/.oh-my-zsh/tools/upgrade.sh"
        else
            log_warning "oh-my-zsh upgrade script not found, skipping oh-my-zsh update"
        fi
        
        # Update custom plugins
        ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
        
        if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
            log_info "Updating zsh-autosuggestions..."
            cd "$ZSH_CUSTOM/plugins/zsh-autosuggestions" && git pull
        fi
        
        if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
            log_info "Updating zsh-syntax-highlighting..."
            cd "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" && git pull
        fi
        
        if [ -d "$ZSH_CUSTOM/plugins/zsh-autocomplete" ]; then
            log_info "Updating zsh-autocomplete..."
            cd "$ZSH_CUSTOM/plugins/zsh-autocomplete" && git pull
        fi
    fi
    
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
        log_info "Tmux prefix key: backtick (\`)"
        log_info "Tmux theme: Dracula with system monitoring"
    else
        log_warning "Tmux not found"
    fi
    
    # Check TWM
    if command -v twm &> /dev/null; then
        log_info "TWM (Tmux Workspace Manager) installed: $(twm --version 2>&1 | head -n1)"
    else
        log_warning "TWM not found"
    fi
    
    # Check clipboard utilities for tmux-yank
    local clipboard_found=false
    if command -v xclip &> /dev/null; then
        log_info "Clipboard utility: xclip (X11)"
        clipboard_found=true
    fi
    if command -v xsel &> /dev/null; then
        log_info "Clipboard utility: xsel (X11)"
        clipboard_found=true
    fi
    if command -v wl-copy &> /dev/null; then
        log_info "Clipboard utility: wl-clipboard (Wayland)"
        clipboard_found=true
    fi
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v pbcopy &> /dev/null; then
            log_info "Clipboard utility: pbcopy (macOS)"
            clipboard_found=true
        fi
    fi
    if [ "$clipboard_found" = false ]; then
        log_warning "No clipboard utility found - tmux-yank will not work!"
        log_warning "Install xclip (X11) or wl-clipboard (Wayland)"
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
    
    # Check Node.js
    if command -v node &> /dev/null; then
        log_info "Node.js version: $(node --version)"
        if [ -n "$NVM_DIR" ]; then
            log_info "Node.js managed by nvm"
        else
            log_info "Node.js managed by system package manager"
        fi
    else
        log_warning "Node.js not found"
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
    log_info ""
    log_info "IMPORTANT: The tmux prefix key is the backtick (\`)"
    log_info "Example: To reload config, press \` then r"
    log_info "Tmux is configured with the Dracula theme for a modern, beautiful appearance."
    log_info ""
    log_info "Please restart your shell to apply configurations."
    log_info "For tmux, you may need to press prefix + I (\` + I) to install plugins on first run."
    log_info ""
    log_info "TMux Workspace Manager (TWM) Usage:"
    log_info "- Press \` then w to open workspace selector"
    log_info "- Press \` then W to open workspace selector with layout picker"
    log_info "- Press \` then T to select existing sessions"
    log_info "- To detach from tmux (preserving session): \` then d"
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
    
    detect_os
    update_repo
    
    # Check and install missing clipboard utilities
    check_and_install_clipboard_utils
    
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
    
    # Remove oh-my-zsh custom plugins
    log_info "Removing oh-my-zsh custom plugins..."
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    rm -rf "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    rm -rf "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    rm -rf "$ZSH_CUSTOM/plugins/zsh-autocomplete"
    
    # Remove neovim plugins and cache
    log_info "Removing neovim plugins and cache..."
    rm -rf ~/.local/share/nvim
    rm -rf ~/.cache/nvim
    rm -rf ~/.config/nvim/lazy-lock.json
    
    # Remove symbolic links and directories
    log_info "Removing configuration links..."
    rm -f ~/.tmux.conf
    
    # Check if ~/.config/nvim is a symlink, file, or directory and remove appropriately
    if [ -L ~/.config/nvim ]; then
        # It's a symbolic link
        rm -f ~/.config/nvim
    elif [ -d ~/.config/nvim ]; then
        # It's a directory
        rm -rf ~/.config/nvim
    elif [ -f ~/.config/nvim ]; then
        # It's a regular file
        rm -f ~/.config/nvim
    fi
    
    # Remove shell configuration entries
    log_info "Cleaning shell profile..."
    if [ -f "$HOME/.zshrc" ]; then
        # Create backup before modifying
        cp "$HOME/.zshrc" "$HOME/.zshrc.goodterminal-purge-backup"
        
        # Remove our configuration block and all GoodTerminal related lines
        sed -i.bak '/# GoodTerminal configuration/,/\[ -f.*goodterminal.*\]/d' "$HOME/.zshrc"
        
        # Also clean up any remaining GoodTerminal references
        sed -i.bak '/GoodTerminal/d' "$HOME/.zshrc"
        sed -i.bak '/goodterminal/d' "$HOME/.zshrc"
        
        
        # Clean up backup files
        rm -f "$HOME/.zshrc.bak"
        
        log_info "Backed up .zshrc to .zshrc.goodterminal-purge-backup"
    fi
    
    if [ -f "$HOME/.bashrc" ]; then
        sed -i.bak '/# GoodTerminal/,/^$/d' "$HOME/.bashrc"
        rm -f "$HOME/.bashrc.bak"
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
            --configure-only)
                configure_installations
                update_plugins
                check_health
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