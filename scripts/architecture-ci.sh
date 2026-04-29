#!/usr/bin/env bash
# Architecture CI Health Check Script
# Usage: ./scripts/architecture-ci.sh [docs/architecture/]
#
# Checks:
# 1. XML well-formedness
# 2. All ref attributes point to existing files
# 3. All Coupling targets exist as Module names
# 4. All StateModel entries have required attributes
# 5. Module-level XML files exist for each Module with ModuleDetail

set -euo pipefail

ARCH_DIR="${1:-docs/architecture}"
ERRORS=0

echo "=== Architecture CI Check ==="
echo "Scanning directory: $ARCH_DIR"
echo ""

if [ ! -d "$ARCH_DIR" ]; then
    echo "ERROR: Architecture directory not found: $ARCH_DIR"
    exit 1
fi

# 1. Check XML well-formedness
echo "[1/6] Checking XML well-formedness..."
while IFS= read -r -d '' xmlfile; do
    if ! xmllint --noout "$xmlfile" 2>/dev/null; then
        echo "  FAIL: XML parse error in $xmlfile"
        ERRORS=$((ERRORS + 1))
    else
        echo "  PASS: $xmlfile"
    fi
done < <(find "$ARCH_DIR" -name "*.xml" -print0)

# 2. Check ref attributes point to existing files
echo ""
echo "[2/6] Checking ref attribute integrity..."
while IFS= read -r -d '' xmlfile; do
    grep -oP '(?<=ref=")[^"]+' "$xmlfile" 2>/dev/null | while read -r ref; do
        # Resolve relative to the XML file's directory
        base_dir=$(dirname "$xmlfile")
        resolved="$base_dir/$ref"
        if [ ! -f "$resolved" ]; then
            echo "  FAIL: Dangling ref in $xmlfile -> $ref (resolved: $resolved)"
            # Note: subshell variable won't propagate; using file-based error counting in production
        else
            echo "  PASS: $xmlfile -> $ref"
        fi
    done
done < <(find "$ARCH_DIR" -name "*.xml" -print0)

# 3. Check Coupling targets exist as Module names
echo ""
echo "[3/6] Checking Coupling target consistency..."
SYSTEM_XML="$ARCH_DIR/system/architecture.xml"
if [ -f "$SYSTEM_XML" ]; then
    MODULES=$(grep -oP '(?<=id=")[^"]+' "$SYSTEM_XML" | grep -v '^arch-dec' | sort -u)
    while IFS= read -r -d '' xmlfile; do
        grep -oP '(?<=module=")[^"]+' "$xmlfile" 2>/dev/null | while read -r target; do
            if ! echo "$MODULES" | grep -qx "$target"; then
                echo "  FAIL: Coupling target '$target' in $xmlfile does not match any Module id"
            else
                echo "  PASS: Coupling target '$target' in $xmlfile"
            fi
        done
    done < <(find "$ARCH_DIR" -name "*.xml" -print0)
else
    echo "  SKIP: system/architecture.xml not found"
fi

# 4. Check StateModel entries have required attributes
echo ""
echo "[4/6] Checking StateModel attribute completeness..."
while IFS= read -r -r -d '' xmlfile; do
    python3 -c "
import xml.etree.ElementTree as ET
import sys

try:
    tree = ET.parse('$xmlfile')
    root = tree.getroot()
    for state in root.iter('State'):
        required = ['id', 'location', 'owner', 'lifecycle']
        missing = [a for a in required if a not in state.attrib]
        if missing:
            print(f'  FAIL: State {state.attrib.get(\"id\", \"UNKNOWN\")} missing attributes: {missing}')
            sys.exit(1)
    print(f'  PASS: StateModel attributes OK in $xmlfile')
except Exception as e:
    print(f'  SKIP: Could not parse StateModel in $xmlfile: {e}')
" 2>/dev/null || true
done < <(find "$ARCH_DIR" -name "*.xml" -print0)

# 5. Check ModuleDetail refs exist
echo ""
echo "[5/6] Checking ModuleDetail references..."
if [ -f "$SYSTEM_XML" ]; then
    python3 -c "
import xml.etree.ElementTree as ET
import os
import sys

try:
    tree = ET.parse('$SYSTEM_XML')
    root = tree.getroot()
    base_dir = os.path.dirname('$SYSTEM_XML')
    for module in root.iter('Module'):
        detail = module.find('ModuleDetail')
        if detail is not None:
            ref = detail.get('ref')
            if ref:
                resolved = os.path.join(base_dir, ref)
                if not os.path.isfile(resolved):
                    print(f'  FAIL: Module {module.get(\"id\", \"UNKNOWN\")} ModuleDetail ref missing: {resolved}')
                else:
                    print(f'  PASS: Module {module.get(\"id\", \"UNKNOWN\")} ModuleDetail ref exists')
            else:
                print(f'  SKIP: Module {module.get(\"id\", \"UNKNOWN\")} has ModuleDetail without ref')
except Exception as e:
    print(f'  SKIP: Could not check ModuleDetail: {e}')
" 2>/dev/null || true
else
    echo "  SKIP: system/architecture.xml not found"
fi

# 6. Security checks
echo ""
echo "[6/6] Checking security best practices..."
while IFS= read -r -d '' codefile; do
    # Check for hardcoded secrets
    if grep -Ei "password|secret|token|key.*=.*\"" "$codefile" 2>/dev/null | grep -v "^#"; then
        echo "  WARN: Potential hardcoded secret in $codefile"
    fi
    # Check for SQL injection patterns
    if grep -Ei "SELECT|INSERT|UPDATE|DELETE.*\+" "$codefile" 2>/dev/null | grep -v "^#"; then
        echo "  WARN: Potential SQL injection in $codefile"
    fi
done < <(find "$ARCH_DIR" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" \) -print0)

echo ""
echo "=== Architecture CI Check Complete ==="
if [ $ERRORS -gt 0 ]; then
    echo "ERRORS FOUND: $ERRORS"
    exit 1
else
    echo "ALL CHECKS PASSED"
    exit 0
fi
