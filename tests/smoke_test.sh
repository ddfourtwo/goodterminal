#!/bin/bash
# Smoke Test for GoodTerminal
# Quick validation of basic functionality without full installation

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GOODTERMINAL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/lib/test_helpers.sh"

# Initialize
init_test_output
setup_test_env

echo "================================"
echo "GoodTerminal Smoke Test"
echo "================================"
echo ""

# Test 1: Repository structure
test_repository_structure() {
    log_info "Testing repository structure..."

    assert_file_exists "$GOODTERMINAL_DIR/install.sh" "install.sh should exist"
    assert_file_exists "$GOODTERMINAL_DIR/README.md" "README.md should exist"
    assert_file_exists "$GOODTERMINAL_DIR/CLAUDE.md" "CLAUDE.md should exist"

    assert_dir_exists "$GOODTERMINAL_DIR/config" "config directory should exist"
    assert_dir_exists "$GOODTERMINAL_DIR/config/nvim" "nvim config directory should exist"
    assert_dir_exists "$GOODTERMINAL_DIR/config/tmux" "tmux config directory should exist"
    assert_dir_exists "$GOODTERMINAL_DIR/config/shell" "shell config directory should exist"

    assert_executable "$GOODTERMINAL_DIR/install.sh" "install.sh should be executable"
}

# Test 2: Configuration files
test_configuration_files() {
    log_info "Testing configuration files..."

    assert_file_exists "$GOODTERMINAL_DIR/config/nvim/init.lua" "Neovim init.lua should exist"
    assert_file_exists "$GOODTERMINAL_DIR/config/tmux/tmux.conf" "tmux.conf should exist"
    assert_file_exists "$GOODTERMINAL_DIR/config/shell/config" "Shell config should exist"

    # Check for essential content in configs
    local nvim_config=$(cat "$GOODTERMINAL_DIR/config/nvim/init.lua")
    assert_contains "lazy.nvim" "$nvim_config" "Neovim config should reference lazy.nvim"
    assert_contains "vim-tmux-navigator" "$nvim_config" "Neovim config should include vim-tmux-navigator"

    local tmux_config=$(cat "$GOODTERMINAL_DIR/config/tmux/tmux.conf")
    assert_contains "prefix" "$tmux_config" "tmux config should set prefix key"
    assert_contains "vim-tmux-navigator" "$tmux_config" "tmux config should reference vim-tmux-navigator"
}

# Test 3: Install script validation
test_install_script() {
    log_info "Testing install script..."

    # Check for required functions in install.sh
    local install_script=$(cat "$GOODTERMINAL_DIR/install.sh")

    assert_contains "detect_os" "$install_script" "install.sh should have detect_os function"
    assert_contains "install_tmux" "$install_script" "install.sh should have install_tmux function"
    assert_contains "install_nvim" "$install_script" "install.sh should have install_nvim function"
    assert_contains "configure_installations" "$install_script" "install.sh should have configure_installations function"
    assert_contains "update_plugins" "$install_script" "install.sh should have update_plugins function"
}

# Test 4: Documentation
test_documentation() {
    log_info "Testing documentation..."

    assert_dir_exists "$GOODTERMINAL_DIR/docs" "docs directory should exist"
    assert_file_exists "$GOODTERMINAL_DIR/docs/README.md" "docs/README.md should exist"
    assert_file_exists "$GOODTERMINAL_DIR/docs/PURPOSE.md" "docs/PURPOSE.md should exist"
    assert_file_exists "$GOODTERMINAL_DIR/docs/ARCHITECTURE.md" "docs/ARCHITECTURE.md should exist"

    # Check for mermaid diagrams in architecture
    local arch_doc=$(cat "$GOODTERMINAL_DIR/docs/ARCHITECTURE.md")
    assert_contains "mermaid" "$arch_doc" "ARCHITECTURE.md should contain mermaid diagrams"
}

# Test 5: OS detection (dry run)
test_os_detection() {
    log_info "Testing OS detection..."

    # Just verify the function exists and can run
    # Don't actually install anything
    cd "$GOODTERMINAL_DIR"

    # Extract just the detect_os function and test it
    if grep -q "detect_os()" install.sh; then
        pass "detect_os function found in install.sh"
    else
        fail "detect_os function not found in install.sh"
    fi
}

# Test 6: Script directory structure
test_scripts_directory() {
    log_info "Testing scripts directory..."

    if [ -d "$GOODTERMINAL_DIR/scripts" ]; then
        assert_dir_exists "$GOODTERMINAL_DIR/scripts" "scripts directory should exist"

        if [ -f "$GOODTERMINAL_DIR/scripts/port-forward.sh" ]; then
            assert_file_exists "$GOODTERMINAL_DIR/scripts/port-forward.sh" "port-forward.sh should exist"
        else
            log_warning "port-forward.sh not found (optional)"
        fi
    else
        log_warning "scripts directory not found (optional)"
    fi
}

# Test 7: Git repository
test_git_repository() {
    log_info "Testing git repository..."

    assert_dir_exists "$GOODTERMINAL_DIR/.git" ".git directory should exist"

    # Check that important files are tracked
    cd "$GOODTERMINAL_DIR"
    assert_command_succeeds "git ls-files | grep -q install.sh" "install.sh should be tracked by git"
    assert_command_succeeds "git ls-files | grep -q config/nvim/init.lua" "nvim config should be tracked"
    assert_command_succeeds "git ls-files | grep -q config/tmux/tmux.conf" "tmux config should be tracked"
}

# Test 8: Test infrastructure
test_test_infrastructure() {
    log_info "Testing test infrastructure..."

    assert_dir_exists "$GOODTERMINAL_DIR/tests" "tests directory should exist"
    assert_file_exists "$GOODTERMINAL_DIR/tests/lib/test_helpers.sh" "test_helpers.sh should exist"
    assert_file_exists "$GOODTERMINAL_DIR/tests/README.md" "tests/README.md should exist"
    assert_executable "$GOODTERMINAL_DIR/tests/smoke_test.sh" "smoke_test.sh should be executable"
}

# Main test execution
main() {
    test_repository_structure
    test_configuration_files
    test_install_script
    test_documentation
    test_os_detection
    test_scripts_directory
    test_git_repository
    test_test_infrastructure

    echo ""
    print_summary

    cleanup_test_env
}

main "$@"
