#!/bin/bash
# Test suite for build-all.sh
# Follows TDD approach: write tests before implementation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_ALL_SCRIPT="$SCRIPT_DIR/build-all.sh"
TEST_DIR=$(mktemp -d)
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

cleanup() {
    # shellcheck disable=SC2317
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

pass() {
    echo -e "${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

# Helper: Create minimal valid Debian packaging for a test source
create_test_source() {
    local source_name="$1"
    local source_dir="$TEST_DIR/sources/$source_name"

    mkdir -p "$source_dir/"{apps,store/debian,upstream}
    touch "$source_dir/store/${source_name}.yaml"

    # Create minimal valid debian/changelog
    cat > "$source_dir/store/debian/changelog" <<EOF
${source_name}-container-store (0.1.0-1) unstable; urgency=medium

  * Initial test release

 -- Test <test@example.com>  $(date -R)
EOF

    # Create minimal valid debian/control
    cat > "$source_dir/store/debian/control" <<EOF
Source: ${source_name}-container-store
Section: admin
Priority: optional
Maintainer: Test <test@example.com>
Build-Depends: debhelper-compat (= 13)

Package: ${source_name}-container-store
Architecture: all
Description: Test package
 Test package for build system
EOF

    # Create minimal debian/rules
    cat > "$source_dir/store/debian/rules" <<'EOF'
#!/usr/bin/make -f
%:
	dh $@
EOF
    chmod +x "$source_dir/store/debian/rules"
}

# Test 1: Script exists and is executable
test_script_exists() {
    if [ -x "$BUILD_ALL_SCRIPT" ]; then
        pass "Script exists and is executable"
    else
        fail "Script does not exist or is not executable"
    fi
}

# Test 2: Run on repository with no sources (should pass with no packages)
test_empty_sources() {
    mkdir -p "$TEST_DIR/sources"
    local exit_code=0
    ( cd "$TEST_DIR" && "$BUILD_ALL_SCRIPT" 2>&1 ) || exit_code=$?

    if [ $exit_code -eq 0 ]; then
        pass "Succeeds on empty sources directory"
    else
        fail "Should succeed on empty sources directory"
    fi
}

# Test 3: Run on repository with one source (should build that source)
test_single_source() {
    create_test_source "source1"

    local exit_code=0
    local output
    output=$( cd "$TEST_DIR" && "$BUILD_ALL_SCRIPT" 2>&1 ) || exit_code=$?

    if [ $exit_code -eq 0 ] && echo "$output" | grep -q "source1"; then
        pass "Builds single source successfully"
    else
        fail "Should build single source successfully"
    fi
}

# Test 4: Run on repository with multiple sources (should build all)
test_multiple_sources() {
    create_test_source "source1"
    create_test_source "source2"

    local exit_code=0
    local output
    output=$( cd "$TEST_DIR" && "$BUILD_ALL_SCRIPT" 2>&1 ) || exit_code=$?

    if [ $exit_code -eq 0 ] && echo "$output" | grep -q "source1" && echo "$output" | grep -q "source2"; then
        pass "Builds multiple sources successfully"
    else
        fail "Should build all sources successfully"
    fi
}

# Test 5: Verify _template directory is skipped
test_template_skipped() {
    mkdir -p "$TEST_DIR/sources/_template"
    create_test_source "realsource"

    local output
    output=$( cd "$TEST_DIR" && "$BUILD_ALL_SCRIPT" 2>&1 )

    if echo "$output" | grep -q "realsource" && ! echo "$output" | grep -q "Building source: _template"; then
        pass "Correctly skips _template directory"
    else
        fail "_template directory should be skipped"
    fi
}

# Test 6: Verify packages from all sources in build/ directory
test_packages_collected() {
    create_test_source "source1"
    create_test_source "source2"

    ( cd "$TEST_DIR" && "$BUILD_ALL_SCRIPT" >/dev/null 2>&1 )

    if [ -d "$TEST_DIR/build" ]; then
        local deb_count
        deb_count=$(find "$TEST_DIR/build" -name "*.deb" 2>/dev/null | wc -l)
        if [ "$deb_count" -ge 2 ]; then
            pass "Packages from all sources collected in build/ directory"
        else
            fail "Should have packages from all sources in build/"
        fi
    else
        fail "build/ directory should exist"
    fi
}

# Test 7: Exit code 0 on successful build
test_exit_code_success() {
    create_test_source "source1"

    local exit_code=0
    ( cd "$TEST_DIR" && "$BUILD_ALL_SCRIPT" >/dev/null 2>&1 ) || exit_code=$?

    if [ $exit_code -eq 0 ]; then
        pass "Exit code is 0 on successful build"
    else
        fail "Exit code should be 0 on successful build"
    fi
}

# Test 8: Prints clear summary at end
test_summary_output() {
    create_test_source "source1"

    local output
    output=$( cd "$TEST_DIR" && "$BUILD_ALL_SCRIPT" 2>&1 )

    if echo "$output" | grep -qi "summary\|total\|completed"; then
        pass "Prints clear summary at end"
    else
        fail "Should print summary at end"
    fi
}

# Run all tests
echo "Running build-all.sh tests..."
echo "======================================="
echo "NOTE: Tests use placeholder build logic"
echo "======================================="

test_script_exists
test_empty_sources
test_single_source
test_multiple_sources
test_template_skipped
test_packages_collected
test_exit_code_success
test_summary_output

echo "======================================="
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"

if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
fi

exit 0
