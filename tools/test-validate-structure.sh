#!/bin/bash
# Test suite for validate-structure.sh
# Follows TDD approach: write tests before implementation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATE_SCRIPT="$SCRIPT_DIR/validate-structure.sh"
TEST_DIR=$(mktemp -d)
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

cleanup() {
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

# Test 1: Script exists and is executable
test_script_exists() {
    if [ -x "$VALIDATE_SCRIPT" ]; then
        pass "Script exists and is executable"
    else
        fail "Script does not exist or is not executable"
    fi
}

# Test 2: Run with no arguments on empty sources directory (should pass)
test_empty_sources() {
    mkdir -p "$TEST_DIR/sources"
    if cd "$TEST_DIR" && "$VALIDATE_SCRIPT" 2>/dev/null; then
        pass "Validates empty sources directory successfully"
    else
        fail "Should pass validation on empty sources directory"
    fi
}

# Test 3: Run with non-existent source name (should fail)
test_nonexistent_source() {
    mkdir -p "$TEST_DIR/sources"
    if cd "$TEST_DIR" && "$VALIDATE_SCRIPT" nonexistent 2>/dev/null; then
        fail "Should fail on non-existent source"
    else
        pass "Correctly fails on non-existent source"
    fi
}

# Test 4: Run with missing required directories (should fail)
test_missing_directories() {
    mkdir -p "$TEST_DIR/sources/testsource"
    # Missing apps/, store/, upstream/ directories
    if cd "$TEST_DIR" && "$VALIDATE_SCRIPT" testsource 2>/dev/null; then
        fail "Should fail when required directories are missing"
    else
        pass "Correctly fails when required directories are missing"
    fi
}

# Test 5: Run with missing required files (should fail)
test_missing_files() {
    mkdir -p "$TEST_DIR/sources/testsource/"{apps,store,upstream}
    # Missing store/*.yaml and upstream/source.yaml
    if cd "$TEST_DIR" && "$VALIDATE_SCRIPT" testsource 2>/dev/null; then
        fail "Should fail when required files are missing"
    else
        pass "Correctly fails when required files are missing"
    fi
}

# Test 6: Run with valid source structure (should pass)
test_valid_structure() {
    mkdir -p "$TEST_DIR/sources/testsource/"{apps,store/debian,upstream}
    touch "$TEST_DIR/sources/testsource/store/testsource.yaml"
    touch "$TEST_DIR/sources/testsource/upstream/source.yaml"
    if cd "$TEST_DIR" && "$VALIDATE_SCRIPT" testsource 2>/dev/null; then
        pass "Validates correct source structure successfully"
    else
        fail "Should pass validation on correct source structure"
    fi
}

# Test 7: Verify _template directory is skipped
test_template_skipped() {
    mkdir -p "$TEST_DIR/sources/_template"
    mkdir -p "$TEST_DIR/sources/validsource/"{apps,store/debian,upstream}
    touch "$TEST_DIR/sources/validsource/store/validsource.yaml"
    touch "$TEST_DIR/sources/validsource/upstream/source.yaml"
    # Should validate validsource but skip _template
    if cd "$TEST_DIR" && "$VALIDATE_SCRIPT" 2>/dev/null; then
        pass "Correctly skips _template directory"
    else
        fail "_template directory should be skipped during validation"
    fi
}

# Test 8: Run with specific source argument
test_specific_source() {
    mkdir -p "$TEST_DIR/sources/source1/"{apps,store/debian,upstream}
    mkdir -p "$TEST_DIR/sources/source2/"{apps,store/debian,upstream}
    touch "$TEST_DIR/sources/source1/store/source1.yaml"
    touch "$TEST_DIR/sources/source1/upstream/source.yaml"
    touch "$TEST_DIR/sources/source2/store/source2.yaml"
    touch "$TEST_DIR/sources/source2/upstream/source.yaml"

    if cd "$TEST_DIR" && "$VALIDATE_SCRIPT" source1 2>/dev/null; then
        pass "Validates specific source when provided as argument"
    else
        fail "Should validate specific source when provided"
    fi
}

# Test 9: Exit code is 0 on success
test_exit_code_success() {
    mkdir -p "$TEST_DIR/sources/testsource/"{apps,store/debian,upstream}
    touch "$TEST_DIR/sources/testsource/store/testsource.yaml"
    touch "$TEST_DIR/sources/testsource/upstream/source.yaml"

    cd "$TEST_DIR" && "$VALIDATE_SCRIPT" testsource >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        pass "Exit code is 0 on successful validation"
    else
        fail "Exit code should be 0 on successful validation"
    fi
}

# Test 10: Exit code is non-zero on failure
test_exit_code_failure() {
    mkdir -p "$TEST_DIR/sources/badsource"
    # Missing required subdirectories

    local exit_code=0
    ( cd "$TEST_DIR" && "$VALIDATE_SCRIPT" badsource >/dev/null 2>&1 ) || exit_code=$?
    if [ $exit_code -ne 0 ]; then
        pass "Exit code is non-zero on validation failure"
    else
        fail "Exit code should be non-zero on validation failure"
    fi
}

# Run all tests
echo "Running validate-structure.sh tests..."
echo "======================================="

test_script_exists
test_empty_sources
test_nonexistent_source
test_missing_directories
test_missing_files
test_valid_structure
test_template_skipped
test_specific_source
test_exit_code_success
test_exit_code_failure

echo "======================================="
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"

if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
fi

exit 0
