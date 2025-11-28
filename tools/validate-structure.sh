#!/bin/bash
# Validate directory structure for halos-imported-containers sources
# Usage: ./validate-structure.sh [source-name]
#   If source-name provided: validates that specific source
#   If no arguments: validates all sources in sources/ (skips _template)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Support running from different directories (for testing)
# If sources/ exists in current directory, use that
# Otherwise, use repository root
if [ -d "./sources" ]; then
    SOURCES_DIR="./sources"
else
    REPO_ROOT="$(dirname "$SCRIPT_DIR")"
    SOURCES_DIR="$REPO_ROOT/sources"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track validation status
VALIDATION_FAILED=0

error() {
    echo -e "${RED}ERROR:${NC} $1" >&2
    VALIDATION_FAILED=1
}

warn() {
    echo -e "${YELLOW}WARNING:${NC} $1" >&2
}

info() {
    echo -e "${GREEN}INFO:${NC} $1"
}

# Validate a single source directory
validate_source() {
    local source_name="$1"
    local source_dir="$SOURCES_DIR/$source_name"

    info "Validating source: $source_name"

    # Check source directory exists
    if [ ! -d "$source_dir" ]; then
        error "Source directory does not exist: $source_dir"
        return 1
    fi

    # Check required directories
    local required_dirs=("apps" "store" "upstream")
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$source_dir/$dir" ]; then
            error "Required directory missing in $source_name: $dir/"
        fi
    done

    # Check for store YAML file (must have exactly one .yaml file in store/)
    if [ ! -d "$source_dir/store" ]; then
        error "Store directory missing in $source_name"
    else
        local yaml_count
        yaml_count=$(find "$source_dir/store" -maxdepth 1 \( -name "*.yaml" -o -name "*.yml" \) -type f | wc -l)
        if [ "$yaml_count" -eq 0 ]; then
            error "No store YAML file found in $source_name/store/"
        elif [ "$yaml_count" -gt 1 ]; then
            warn "Multiple YAML files found in $source_name/store/ (expected 1)"
        fi

        # Validate YAML syntax if yq is available
        if command -v yq &> /dev/null; then
            for yaml_file in "$source_dir/store"/*.{yaml,yml}; do
                [ -f "$yaml_file" ] || continue
                if ! yq eval . "$yaml_file" >/dev/null 2>&1; then
                    error "Invalid YAML syntax in $(basename "$yaml_file")"
                fi
            done
        fi
    fi

    # Check for upstream source.yaml
    if [ ! -f "$source_dir/upstream/source.yaml" ]; then
        error "Required file missing in $source_name: upstream/source.yaml"
    else
        # Validate YAML syntax if yq is available
        if command -v yq &> /dev/null; then
            if ! yq eval . "$source_dir/upstream/source.yaml" >/dev/null 2>&1; then
                error "Invalid YAML syntax in upstream/source.yaml"
            fi
        fi
    fi

    # Check for store/debian directory (required for Debian packaging)
    if [ ! -d "$source_dir/store/debian" ]; then
        error "Required directory missing in $source_name: store/debian/"
    fi

    if [ $VALIDATION_FAILED -eq 0 ]; then
        info "✓ Source $source_name validated successfully"
    else
        error "✗ Source $source_name validation failed"
    fi
}

# Main validation logic
main() {
    # Check if sources directory exists
    if [ ! -d "$SOURCES_DIR" ]; then
        error "Sources directory does not exist: $SOURCES_DIR"
        exit 1
    fi

    if [ $# -eq 0 ]; then
        # No arguments: validate all sources (skip _template)
        info "Validating all sources in $SOURCES_DIR"

        # Check if sources directory is empty
        local source_count
        source_count=$(find "$SOURCES_DIR" -mindepth 1 -maxdepth 1 -type d ! -name "_template" | wc -l)
        if [ "$source_count" -eq 0 ]; then
            info "No sources found to validate (empty sources directory is valid)"
            exit 0
        fi

        # Iterate through all source directories
        for source_dir in "$SOURCES_DIR"/*; do
            if [ -d "$source_dir" ]; then
                source_name=$(basename "$source_dir")

                # Skip _template directory
                if [ "$source_name" = "_template" ]; then
                    info "Skipping template directory: _template"
                    continue
                fi

                validate_source "$source_name"
            fi
        done
    else
        # Specific source provided
        local source_name="$1"

        # Check if source is _template (not allowed to validate)
        if [ "$source_name" = "_template" ]; then
            error "Cannot validate _template directory (templates are not sources)"
            exit 1
        fi

        validate_source "$source_name"
    fi

    # Exit with appropriate code
    if [ $VALIDATION_FAILED -eq 1 ]; then
        error "Validation failed"
        exit 1
    fi

    info "All validations passed successfully"
    exit 0
}

main "$@"
