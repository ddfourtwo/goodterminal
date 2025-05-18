#!/bin/bash

# Continue installation from configuration step
cd "$(dirname "$0")"

# Set up colors
GREEN='\033[0;32m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Direct inline approach without menu
log_info "Continuing GoodTerminal installation..."

# Source the install script functions without running main
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Run specific functions from install.sh
bash -c "
source $SCRIPT_DIR/install.sh
configure_installations
update_plugins
check_health
" < /dev/null

log_info "Installation continued successfully!"