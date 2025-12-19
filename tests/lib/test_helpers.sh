#!/bin/bash
# Test Helper Functions for GoodTerminal Test Suite

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test output
TEST_OUTPUT_FILE="${TEST_OUTPUT_FILE:-/tmp/goodterminal_test_output.log}"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$TEST_OUTPUT_FILE"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1" | tee -a "$TEST_OUTPUT_FILE"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1" | tee -a "$TEST_OUTPUT_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$TEST_OUTPUT_FILE"
}

# Test result tracking
pass() {
    local message="$1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
    log_success "$message"
}

fail() {
    local message="$1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
    log_error "$message"
}

# Print test summary
print_summary() {
    echo ""
    echo "================================"
    echo "Test Summary"
    echo "================================"
    echo "Total:  $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo "================================"

    if [ "$TESTS_FAILED" -gt 0 ]; then
        echo -e "${RED}Tests FAILED${NC}"
        return 1
    else
        echo -e "${GREEN}All tests PASSED${NC}"
        return 0
    fi
}

# Assertion functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    if [ "$expected" = "$actual" ]; then
        pass "$message"
    else
        fail "$message (expected: '$expected', got: '$actual')"
    fi
}

assert_not_equals() {
    local not_expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    if [ "$not_expected" != "$actual" ]; then
        pass "$message"
    else
        fail "$message (expected NOT to equal: '$not_expected', but got: '$actual')"
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: $file}"

    if [ -f "$file" ]; then
        pass "$message"
    else
        fail "$message"
    fi
}

assert_file_not_exists() {
    local file="$1"
    local message="${2:-File should not exist: $file}"

    if [ ! -f "$file" ]; then
        pass "$message"
    else
        fail "$message"
    fi
}

assert_dir_exists() {
    local dir="$1"
    local message="${2:-Directory should exist: $dir}"

    if [ -d "$dir" ]; then
        pass "$message"
    else
        fail "$message"
    fi
}

assert_dir_not_exists() {
    local dir="$1"
    local message="${2:-Directory should not exist: $dir}"

    if [ ! -d "$dir" ]; then
        pass "$message"
    else
        fail "$message"
    fi
}

assert_command_succeeds() {
    local command="$1"
    local message="${2:-Command should succeed: $command}"

    if eval "$command" >> "$TEST_OUTPUT_FILE" 2>&1; then
        pass "$message"
    else
        fail "$message (exit code: $?)"
    fi
}

assert_command_fails() {
    local command="$1"
    local message="${2:-Command should fail: $command}"

    if ! eval "$command" >> "$TEST_OUTPUT_FILE" 2>&1; then
        pass "$message"
    else
        fail "$message (expected failure, but command succeeded)"
    fi
}

assert_contains() {
    local substring="$1"
    local string="$2"
    local message="${3:-String should contain substring}"

    if echo "$string" | grep -q "$substring"; then
        pass "$message"
    else
        fail "$message (substring: '$substring' not found in: '$string')"
    fi
}

assert_not_contains() {
    local substring="$1"
    local string="$2"
    local message="${3:-String should not contain substring}"

    if ! echo "$string" | grep -q "$substring"; then
        pass "$message"
    else
        fail "$message (substring: '$substring' found in: '$string')"
    fi
}

assert_is_symlink() {
    local path="$1"
    local message="${2:-Path should be a symlink: $path}"

    if [ -L "$path" ]; then
        pass "$message"
    else
        fail "$message"
    fi
}

assert_is_not_symlink() {
    local path="$1"
    local message="${2:-Path should not be a symlink: $path}"

    if [ ! -L "$path" ]; then
        pass "$message"
    else
        fail "$message"
    fi
}

assert_executable() {
    local file="$1"
    local message="${2:-File should be executable: $file}"

    if [ -x "$file" ]; then
        pass "$message"
    else
        fail "$message"
    fi
}

assert_version_ge() {
    local version="$1"
    local min_version="$2"
    local message="${3:-Version should be >= $min_version}"

    # Simple version comparison (works for X.Y.Z format)
    if [ "$(printf '%s\n' "$min_version" "$version" | sort -V | head -n1)" = "$min_version" ]; then
        pass "$message"
    else
        fail "$message (version: $version, required: >= $min_version)"
    fi
}

# Utility functions
run_command() {
    local command="$1"
    log_info "Running: $command"
    eval "$command"
}

setup_test_env() {
    log_info "Setting up test environment"
    export TEST_MODE=1
    export GOODTERMINAL_DIR="${GOODTERMINAL_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
    log_info "GoodTerminal directory: $GOODTERMINAL_DIR"
}

cleanup_test_env() {
    log_info "Cleaning up test environment"
    # Add cleanup logic here if needed
}

# Docker helpers
docker_run_test() {
    local os_image="$1"
    local test_script="$2"

    log_info "Running test in Docker: $os_image"

    docker run --rm \
        -v "$GOODTERMINAL_DIR:/goodterminal" \
        -w /goodterminal \
        "$os_image" \
        bash -c "$test_script"
}

# Wait for condition
wait_for() {
    local condition="$1"
    local timeout="${2:-30}"
    local interval="${3:-1}"
    local elapsed=0

    while ! eval "$condition" >> "$TEST_OUTPUT_FILE" 2>&1; do
        if [ "$elapsed" -ge "$timeout" ]; then
            log_error "Timeout waiting for: $condition"
            return 1
        fi
        sleep "$interval"
        elapsed=$((elapsed + interval))
    done

    return 0
}

# Backup and restore
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "${file}.test_backup"
        log_info "Backed up: $file"
    fi
}

restore_file() {
    local file="$1"
    if [ -f "${file}.test_backup" ]; then
        mv "${file}.test_backup" "$file"
        log_info "Restored: $file"
    fi
}

# Mock functions for testing
mock_command() {
    local command="$1"
    local mock_output="$2"

    eval "${command}() { echo '$mock_output'; }"
    log_info "Mocked command: $command"
}

# Test fixture helpers
load_fixture() {
    local fixture_name="$1"
    local fixture_path="${GOODTERMINAL_DIR}/tests/fixtures/${fixture_name}"

    if [ -f "$fixture_path" ]; then
        cat "$fixture_path"
    else
        log_error "Fixture not found: $fixture_path"
        return 1
    fi
}

# Initialize test output file
init_test_output() {
    : > "$TEST_OUTPUT_FILE"
    log_info "Test output file: $TEST_OUTPUT_FILE"
}

# Export all functions
export -f log_info
export -f log_success
export -f log_error
export -f log_warning
export -f pass
export -f fail
export -f print_summary
export -f assert_equals
export -f assert_not_equals
export -f assert_file_exists
export -f assert_file_not_exists
export -f assert_dir_exists
export -f assert_dir_not_exists
export -f assert_command_succeeds
export -f assert_command_fails
export -f assert_contains
export -f assert_not_contains
export -f assert_is_symlink
export -f assert_is_not_symlink
export -f assert_executable
export -f assert_version_ge
export -f run_command
export -f setup_test_env
export -f cleanup_test_env
export -f docker_run_test
export -f wait_for
export -f backup_file
export -f restore_file
export -f mock_command
export -f load_fixture
export -f init_test_output
