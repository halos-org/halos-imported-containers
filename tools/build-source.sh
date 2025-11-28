#!/bin/bash
# Build all packages (store + apps) for a specific source
# Usage: ./build-source.sh <source-name>
#
# Prerequisites:
#   - container-packaging-tools (for building app packages)
#   - Debian packaging tools: dpkg-buildpackage, debhelper

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Support running from different directories (for testing)
if [ -d "./sources" ]; then
    SOURCES_DIR="./sources"
    BUILD_DIR="./build"
else
    REPO_ROOT="$(dirname "$SCRIPT_DIR")"
    SOURCES_DIR="$REPO_ROOT/sources"
    BUILD_DIR="$REPO_ROOT/build"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

error() {
    echo -e "${RED}ERROR:${NC} $1" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}WARNING:${NC} $1" >&2
}

info() {
    echo -e "${GREEN}INFO:${NC} $1"
}

step() {
    echo -e "${BLUE}==>${NC} $1"
}

usage() {
    cat <<EOF
Usage: $0 <source-name>

Build all packages (store + apps) for a specific source.

Arguments:
  source-name    Name of the source to build (e.g., casaos-official)

Examples:
  $0 casaos-official
  $0 runtipi

Prerequisites:
  - container-packaging-tools installed (pip install or uv tool install)
  - Debian packaging tools: dpkg-buildpackage, debhelper
EOF
    exit 1
}

# Check prerequisites
check_prerequisites() {
    local missing_tools=()

    # Check for dpkg-buildpackage
    if ! command -v dpkg-buildpackage &> /dev/null; then
        missing_tools+=("dpkg-buildpackage (install: apt install dpkg-dev)")
    fi

    # Check for debhelper
    if ! command -v dh &> /dev/null; then
        missing_tools+=("debhelper (install: apt install debhelper)")
    fi

    # Check for container-packaging-tools (TODO: Add when ready)
    # For now, we'll build a placeholder since the tool isn't available yet
    # if ! command -v container-pkg &> /dev/null; then
    #     missing_tools+=("container-packaging-tools (install: uv tool install ...)")
    # fi

    if [ ${#missing_tools[@]} -gt 0 ]; then
        warn "Some build tools are missing:"
        for tool in "${missing_tools[@]}"; do
            echo "  - $tool"
        done
        warn "Build may fail. Install missing tools or continue for testing."
    fi
}

# Build store package using Debian packaging
build_store_package() {
    local source_name="$1"
    local source_dir="$SOURCES_DIR/$source_name"
    local store_dir="$source_dir/store"

    step "Building store package: ${source_name}-container-store"

    if [ ! -d "$store_dir/debian" ]; then
        error "Store Debian packaging directory not found: $store_dir/debian"
    fi

    # TODO: Implement actual dpkg-buildpackage call when Debian packaging is ready
    # For now, just validate the structure exists
    info "Store package build logic placeholder (requires Debian packaging setup)"
    info "Would execute: dpkg-buildpackage -us -uc -b in $store_dir"

    # Create a placeholder .deb file for testing
    # TODO: Extract version from debian/changelog when implementing real build
    local package_name="${source_name}-container-store"
    local version="0.1.0"  # Hard-coded for placeholder only
    touch "$BUILD_DIR/${package_name}_${version}_all.deb"
    info "Created placeholder: ${package_name}_${version}_all.deb"
}

# Build app packages using container-packaging-tools
build_app_packages() {
    local source_name="$1"
    local source_dir="$SOURCES_DIR/$source_name"
    local apps_dir="$source_dir/apps"

    step "Building app packages for source: $source_name"

    if [ ! -d "$apps_dir" ]; then
        error "Apps directory not found: $apps_dir"
    fi

    # Count apps
    local app_count
    app_count=$(find "$apps_dir" -mindepth 1 -maxdepth 1 -type d | wc -l)
    if [ "$app_count" -eq 0 ]; then
        info "No apps found in $apps_dir (store-only package)"
        return 0
    fi

    info "Found $app_count apps to build"

    # TODO: Implement container-packaging-tools build when ready
    # For each app in apps_dir:
    #   - Run container-pkg build or equivalent
    #   - Move .deb file to BUILD_DIR
    # For now, just iterate and create placeholders

    for app_dir in "$apps_dir"/*; do
        if [ -d "$app_dir" ]; then
            local app_name
            app_name=$(basename "$app_dir")
            local package_name="${source_name}-${app_name}-container"
            # TODO: Extract version from metadata.yaml when implementing real build
            local version="1.0.0"  # Hard-coded for placeholder only

            info "Would build: $package_name"
            # TODO: Replace with actual build command
            # container-pkg build "$app_dir" --output "$BUILD_DIR"

            # Create placeholder for testing
            touch "$BUILD_DIR/${package_name}_${version}_all.deb"
            info "Created placeholder: ${package_name}_${version}_all.deb"
        fi
    done
}

# Print build summary
print_summary() {
    local source_name="$1"

    step "Build Summary for $source_name"

    if [ ! -d "$BUILD_DIR" ]; then
        warn "Build directory not found: $BUILD_DIR"
        return
    fi

    local deb_count
    deb_count=$(find "$BUILD_DIR" -name "*.deb" | wc -l)
    info "Total packages built: $deb_count"

    if [ "$deb_count" -gt 0 ]; then
        echo "Packages:"
        find "$BUILD_DIR" -name "*.deb" -exec basename {} \; | sort | sed 's/^/  - /'
    fi
}

# Main build logic
main() {
    # Check arguments
    if [ $# -eq 0 ]; then
        error "Missing required argument: source-name\n\n$(usage)"
    fi

    local source_name="$1"
    local source_dir="$SOURCES_DIR/$source_name"

    # Validate source exists
    if [ ! -d "$source_dir" ]; then
        error "Source directory does not exist: $source_dir"
    fi

    # Check if source is _template
    if [ "$source_name" = "_template" ]; then
        error "Cannot build _template directory (templates are not sources)"
    fi

    info "Building source: $source_name"

    # Check prerequisites (warnings only, don't fail)
    check_prerequisites

    # Create build directory
    mkdir -p "$BUILD_DIR"
    step "Build directory: $BUILD_DIR"

    # Build store package
    build_store_package "$source_name"

    # Build app packages
    build_app_packages "$source_name"

    # Print summary
    print_summary "$source_name"

    info "Build completed successfully for $source_name"
}

main "$@"
