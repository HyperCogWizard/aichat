#!/usr/bin/env bash
set -e

echo "Testing llm-functions integration..."

# Test 1: Check if tools exist
echo "1. Checking tools directory..."
if [[ ! -d "tools" ]]; then
    echo "❌ Tools directory not found"
    exit 1
fi
echo "✅ Tools directory exists"

# Test 2: Check if scripts exist
echo "2. Checking script runners..."
for script in scripts/run-tool.sh scripts/run-tool.js scripts/run-tool.py; do
    if [[ ! -f "$script" ]]; then
        echo "❌ Script runner not found: $script"
        exit 1
    fi
done
echo "✅ All script runners exist"

# Test 3: Check if functions.json exists and is valid
echo "3. Checking functions.json..."
if [[ ! -f "functions/functions.json" ]]; then
    echo "❌ functions.json not found"
    exit 1
fi

if ! jq . functions/functions.json >/dev/null 2>&1; then
    echo "❌ functions.json is not valid JSON"
    exit 1
fi

tool_count=$(jq length functions/functions.json)
echo "✅ functions.json is valid with $tool_count tools"

# Test 4: Test declaration generation
echo "4. Testing declaration generation..."
if [[ -f "tools/get_current_time.sh" ]]; then
    declaration=$(bash scripts/build-declarations.sh tools/get_current_time.sh)
    if echo "$declaration" | jq . >/dev/null 2>&1; then
        echo "✅ Declaration generation works"
    else
        echo "❌ Declaration generation failed"
        exit 1
    fi
else
    echo "❌ Test tool not found"
    exit 1
fi

# Test 5: Test basic tool execution
echo "5. Testing tool execution..."
if [[ -f "tools/get_current_time.sh" ]]; then
    # Test with simple JSON args
    result=$(bash scripts/run-tool.sh get_current_time '{}' 2>/dev/null || echo "failed")
    if [[ "$result" != "failed" ]]; then
        echo "✅ Tool execution works"
    else
        echo "❌ Tool execution failed"
        exit 1
    fi
else
    echo "❌ Test tool not found"
    exit 1
fi

echo ""
echo "🎉 All tests passed! llm-functions integration is working correctly."
echo ""
echo "Available tools:"
jq -r '.[].name' functions/functions.json | sed 's/^/  - /'

echo ""
echo "Available agents:"
if [[ -f "agents.txt" ]]; then
    cat agents.txt | sed 's/^/  - /'
else
    echo "  - No agents configured"
fi