#!/usr/bin/env bash
set -e

# Build function declarations from bash tool files
# Usage: build-declarations.sh <tool_file>

tool_file="$1"
if [[ ! -f "$tool_file" ]]; then
    echo "Tool file not found: $tool_file" >&2
    exit 1
fi

# Extract function name from filename
function_name=$(basename "$tool_file" .sh)

# Parse comments to extract function declaration
description=""
options=()
envs=()
required_props_list=()

while IFS= read -r line; do
    if [[ "$line" =~ ^#[[:space:]]*@describe[[:space:]]+(.+)$ ]]; then
        description="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^#[[:space:]]*@option[[:space:]]+--([^[:space:]!=]+)(=([^[:space:]!]+))?(!?)[[:space:]]*(.*)$ ]]; then
        option_name="${BASH_REMATCH[1]}"
        default_value="${BASH_REMATCH[3]}"
        required="${BASH_REMATCH[4]}"
        option_desc="${BASH_REMATCH[5]}"
        
        # Build option definition
        option_def="{\"type\": \"string\", \"description\": \"$option_desc\""
        if [[ -n "$default_value" ]]; then
            option_def="$option_def, \"default\": \"$default_value\""
        fi
        option_def="$option_def}"
        
        options+=("\"$option_name\": $option_def")
        
        # Add to required if marked with !
        if [[ "$required" == "!" ]]; then
            required_props_list+=("\"$option_name\"")
        fi
    elif [[ "$line" =~ ^#[[:space:]]*@env[[:space:]]+([^[:space:]!]+)(!?)[[:space:]]*(.*)$ ]]; then
        env_name="${BASH_REMATCH[1]}"
        required="${BASH_REMATCH[2]}"
        env_desc="${BASH_REMATCH[3]}"
        envs+=("$env_name: $env_desc")
    fi
done < "$tool_file"

# Generate function declaration JSON
properties=""
required_props=""

if [[ ${#options[@]} -gt 0 ]]; then
    properties=$(IFS=,; echo "${options[*]}")
fi

if [[ ${#required_props_list[@]} -gt 0 ]]; then
    required_props="\"required\": [$(IFS=,; echo "${required_props_list[*]}")],"
fi

# Output JSON declaration
cat << EOF
{
  "name": "$function_name",
  "description": "$description",
  "parameters": {
    "type": "object",
    $required_props
    "properties": {
      $properties
    }
  }
}
EOF