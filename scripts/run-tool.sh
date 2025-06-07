#!/usr/bin/env bash
set -e

# Tool runner for bash tools
# Usage: run-tool.sh <tool_name> <json_args>

tool_name="$1"
json_args="$2"

if [[ -z "$tool_name" || -z "$json_args" ]]; then
    echo "Usage: $0 <tool_name> <json_args>" >&2
    exit 1
fi

# Find the tool script
tool_script="tools/${tool_name}.sh"
if [[ ! -f "$tool_script" ]]; then
    echo "Tool not found: $tool_script" >&2
    exit 1
fi

# Parse JSON arguments and convert to argc format
temp_file=$(mktemp)
echo "$json_args" > "$temp_file"

# Convert JSON to command line arguments
args=()
while IFS= read -r key; do
    value=$(echo "$json_args" | jq -r ".$key")
    if [[ "$value" != "null" ]]; then
        args+=("--$key" "$value")
    fi
done < <(echo "$json_args" | jq -r 'keys[]')

# Execute the tool
"$tool_script" "${args[@]}"

# Cleanup
rm -f "$temp_file"