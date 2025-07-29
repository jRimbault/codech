#!/bin/bash
# Linting script for shell scripts in the codech project

set -e

echo "Running shellcheck on all shell scripts..."
echo "=========================================="

# Find and check all shell scripts
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
SCRIPTS=("$SCRIPT_DIR"/*.sh)

# Check if shellcheck is available
if ! command -v shellcheck &> /dev/null; then
    echo "Error: shellcheck is not installed"
    echo "Install with: apt-get install shellcheck (Ubuntu/Debian)"
    echo "             brew install shellcheck (macOS)"
    exit 1
fi

echo "Checking ${#SCRIPTS[@]} shell scripts..."
echo ""

FAILED=0

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo "Checking $(basename "$script")..."
        if shellcheck "$script"; then
            echo "✅ $(basename "$script") passed"
        else
            echo "❌ $(basename "$script") failed"
            FAILED=$((FAILED + 1))
        fi
        echo ""
    fi
done

echo "=========================================="
if [ $FAILED -eq 0 ]; then
    echo "🎉 All scripts passed shellcheck!"
    exit 0
else
    echo "💥 $FAILED script(s) failed shellcheck"
    exit 1
fi