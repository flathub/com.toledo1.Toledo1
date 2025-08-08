#!/bin/bash
set -e

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_section() {
    print_message "${GREEN}" "\n==> $1\n"
}

# 1. Clean up previous builds
print_section "Cleaning up previous builds"
rm -rf builddir repo .flatpak-builder

# 2. Build the application
print_section "Building Toledo1"
print_message "${YELLOW}" "This may take a while..."
print_message "${YELLOW}" "Note: ccache warnings will be ignored."
CCACHE_DISABLE=1 flatpak run org.flatpak.Builder --force-clean --user --repo=repo builddir com.toledo1.Toledo1.yaml

# 3. Verify build success
print_section "Verifying build"
if [ ! -f "repo/refs/heads/app/com.toledo1.Toledo1/x86_64/master" ]; then
    print_message "${RED}" "Build failed: Repository not created."
    exit 1
fi
print_message "${GREEN}" "Build successful!"

# 4. Set up local repository
print_section "Setting up local repository"
flatpak --user remote-add --no-gpg-verify --if-not-exists toledo1-local repo
print_message "${GREEN}" "Local repository 'toledo1-local' configured."

# 5. Install the application
print_section "Installing Toledo1"
flatpak --user install --assumeyes toledo1-local com.toledo1.Toledo1
print_message "${GREEN}" "Toledo1 installed successfully."

# 6. Run the application
print_section "Running Toledo1"
flatpak run com.toledo1.Toledo1
