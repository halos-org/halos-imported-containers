#!/bin/bash
# Build all sources in the repository
# Usage: ./build-all.sh
#
# Iterates through all sources in sources/ directory (skipping _template)
# and builds each one using build-source.sh.
#
# Behavior: Continue on error - builds all sources even if some fail.
# Exit code reflects overall success (0) or failure (non-zero).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_SOURCE_SCRIPT="$SCRIPT_DIR/build-source.sh"

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

# Track build results
declare -a SUCCESSFUL_SOURCES=()
declare -a FAILED_SOURCES=()
TOTAL_SOURCES=0

# Build a single source
build_source() {
    local source_name="$1"
    local exit_code=0

    step "Building source: $source_name"
    ( "$BUILD_SOURCE_SCRIPT" "$source_name" ) || exit_code=$?

    if [ $exit_code -eq 0 ]; then
        SUCCESSFUL_SOURCES+=("$source_name")
        info "✓ Successfully built $source_name"
    else
        FAILED_SOURCES+=("$source_name")
        error "✗ Failed to build $source_name (exit code: $exit_code)"
    fi

    echo ""  # Blank line between sources
}

# Print build summary
print_summary() {
    step "Build Summary"

    local successful_count=${#SUCCESSFUL_SOURCES[@]}
    local failed_count=${#FAILED_SOURCES[@]}

    info "Total sources processed: $TOTAL_SOURCES"
    info "Successful builds: $successful_count"

    if [ "$successful_count" -gt 0 ]; then
        echo "Successfully built sources:"
        for source in "${SUCCESSFUL_SOURCES[@]}"; do
            echo -e "  ${GREEN}✓${NC} $source"
        done
    fi

    if [ "$failed_count" -gt 0 ]; then
        warn "Failed builds: $failed_count"
        echo "Failed sources:"
        for source in "${FAILED_SOURCES[@]}"; do
            echo -e "  ${RED}✗${NC} $source"
        done
    fi

    # Package summary
    if [ -d "$BUILD_DIR" ]; then
        local deb_count
        deb_count=$(find "$BUILD_DIR" -name "*.deb" 2>/dev/null | wc -l)
        info "Total packages in build/: $deb_count"
    fi

    echo ""
    if [ "$failed_count" -gt 0 ]; then
        error "Build completed with failures"
        return 1
    else
        info "All builds completed successfully"
        return 0
    fi
}

# Main build logic
main() {
    info "Building all sources from: $SOURCES_DIR"

    # Check if sources directory exists
    if [ ! -d "$SOURCES_DIR" ]; then
        error "Sources directory does not exist: $SOURCES_DIR"
        exit 1
    fi

    # Create build directory
    mkdir -p "$BUILD_DIR"
    info "Build directory: $BUILD_DIR"
    echo ""

    # Check if build-source.sh exists
    if [ ! -x "$BUILD_SOURCE_SCRIPT" ]; then
        error "build-source.sh not found or not executable: $BUILD_SOURCE_SCRIPT"
        exit 1
    fi

    # Find all source directories
    local source_dirs=()
    for source_dir in "$SOURCES_DIR"/*; do
        if [ -d "$source_dir" ]; then
            local source_name
            source_name=$(basename "$source_dir")

            # Skip _template directory
            if [ "$source_name" = "_template" ]; then
                info "Skipping template directory: _template"
                continue
            fi

            source_dirs+=("$source_name")
        fi
    done

    # Check if any sources found
    if [ ${#source_dirs[@]} -eq 0 ]; then
        info "No sources found to build (empty sources directory)"
        info "All builds completed successfully"
        exit 0
    fi

    TOTAL_SOURCES=${#source_dirs[@]}
    info "Found $TOTAL_SOURCES sources to build"
    echo ""

    # Build each source (continue on error)
    for source_name in "${source_dirs[@]}"; do
        # Continue on error to build all sources even if some fail
        build_source "$source_name" || true
    done

    # Print summary and exit
    if print_summary; then
        exit 0
    else
        exit 1
    fi
}

main "$@"
