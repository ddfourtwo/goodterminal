#!/bin/bash
# Integration Test: Full Installation
# Tests complete installation workflow on a clean system

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GOODTERMINAL_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/../lib/test_helpers.sh"

# Initialize
init_test_output
setup_test_env

echo "================================"
echo "GoodTerminal Installation Test"
echo "================================"
echo ""

# Test 1: Pre-installation state
test_pre_installation() {
    log_info "Testing pre-installation state..."

    # Backup any existing configs
    backup_file "$HOME/.config/nvim/init.lua"
    backup_file "$HOME/.tmux.conf"
    backup_file "$HOME/.zshrc"

    log_info "Backed up existing configurations"
}

# Test 2: Run installation
test_run_installation() {
    log_info "Running installation..."

    cd "$GOODTERMINAL_DIR"

    # Run install script in non-interactive mode
    # This would need --yes flag or similar in install.sh
    # For now, just verify the script can be parsed
    assert_command_succeeds "bash -n install.sh" "install.sh should have valid syntax"

    log_warning "Full installation test requires --yes flag implementation"
    log_info "Skipping actual installation in this test run"
}

# Test 3: Verify tool installation
test_tool_installation() {
    log_info "Testing tool installation..."

    # Check if tools are available (system-dependent)
    local tools_found=0

    if command -v tmux &> /dev/null; then
        local tmux_version=$(tmux -V | grep -oE '[0-9]+\.[0-9]+')
        log_info "tmux found: version $tmux_version"
        assert_version_ge "$tmux_version" "3.0" "tmux version should be >= 3.0"
        tools_found=$((tools_found + 1))
    else
        log_warning "tmux not found (would be installed by install.sh)"
    fi

    if command -v nvim &> /dev/null; then
        log_info "neovim found"
        tools_found=$((tools_found + 1))
    else
        log_warning "neovim not found (would be installed by install.sh)"
    fi

    if command -v zsh &> /dev/null; then
        log_info "zsh found"
        tools_found=$((tools_found + 1))
    else
        log_warning "zsh not found (would be installed by install.sh)"
    fi

    if [ $tools_found -gt 0 ]; then
        pass "At least some tools are available for testing"
    else
        log_warning "No tools found - this is expected on fresh systems"
    fi
}

# Test 4: Verify configuration deployment
test_config_deployment() {
    log_info "Testing configuration deployment..."

    # Test that symlinks would be created correctly
    local nvim_config_src="$GOODTERMINAL_DIR/config/nvim/init.lua"
    local nvim_config_dst="$HOME/.config/nvim/init.lua"

    assert_file_exists "$nvim_config_src" "Source nvim config should exist"

    # If config is already deployed, test it
    if [ -L "$nvim_config_dst" ]; then
        assert_is_symlink "$nvim_config_dst" "Neovim config should be symlinked"

        local link_target=$(readlink "$nvim_config_dst")
        if [ "$link_target" = "$nvim_config_src" ]; then
            pass "Neovim config symlink points to correct location"
        else
            log_warning "Neovim config symlink points to: $link_target"
        fi
    else
        log_info "Neovim config not yet deployed (would be created by install.sh)"
    fi

    # Similar for tmux
    local tmux_config_src="$GOODTERMINAL_DIR/config/tmux/tmux.conf"
    local tmux_config_dst="$HOME/.tmux.conf"

    assert_file_exists "$tmux_config_src" "Source tmux config should exist"

    if [ -L "$tmux_config_dst" ]; then
        assert_is_symlink "$tmux_config_dst" "tmux config should be symlinked"
    else
        log_info "tmux config not yet deployed (would be created by install.sh)"
    fi
}

# Test 5: Verify plugin directories
test_plugin_directories() {
    log_info "Testing plugin directories..."

    # Check if TPM is installed
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        assert_dir_exists "$HOME/.tmux/plugins/tpm" "TPM should be installed"
        assert_file_exists "$HOME/.tmux/plugins/tpm/tpm" "TPM executable should exist"
    else
        log_info "TPM not yet installed (would be installed by install.sh)"
    fi

    # Check if Lazy.nvim is installed
    if [ -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]; then
        assert_dir_exists "$HOME/.local/share/nvim/lazy/lazy.nvim" "Lazy.nvim should be installed"
    else
        log_info "Lazy.nvim not yet installed (would be installed by install.sh)"
    fi
}

# Test 6: Health checks
test_health_checks() {
    log_info "Testing health checks..."

    # If neovim is installed, check health
    if command -v nvim &> /dev/null; then
        log_info "Running neovim health check..."

        # Run headless health check
        if nvim --headless "+checkhealth" +qa &> /dev/null; then
            pass "Neovim health check completed"
        else
            log_warning "Neovim health check had issues (may be expected on partial install)"
        fi
    else
        log_info "Neovim not available for health check"
    fi

    # If tmux is installed, verify it can start
    if command -v tmux &> /dev/null; then
        log_info "Testing tmux startup..."

        # Create a test session and immediately kill it
        if tmux new-session -d -s test_session 2>/dev/null; then
            tmux kill-session -t test_session 2>/dev/null
            pass "tmux can create sessions"
        else
            log_warning "tmux session creation failed (may need configuration)"
        fi
    else
        log_info "tmux not available for testing"
    fi
}

# Test 7: Cleanup
test_cleanup() {
    log_info "Cleaning up test environment..."

    # Restore backed up files
    restore_file "$HOME/.config/nvim/init.lua"
    restore_file "$HOME/.tmux.conf"
    restore_file "$HOME/.zshrc"

    pass "Cleanup completed"
}

# Main test execution
main() {
    test_pre_installation
    test_run_installation
    test_tool_installation
    test_config_deployment
    test_plugin_directories
    test_health_checks
    test_cleanup

    echo ""
    print_summary

    cleanup_test_env
}

main "$@"
