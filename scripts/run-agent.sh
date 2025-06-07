#!/usr/bin/env bash
set -e

# Agent runner for bash-based agent tools
# Usage: run-agent.sh <agent_name> <action> <json_args>

agent_name="$1"
action="$2"
json_args="$3"

if [[ -z "$agent_name" || -z "$action" || -z "$json_args" ]]; then
    echo "Usage: $0 <agent_name> <action> <json_args>" >&2
    exit 1
fi

# Find the agent directory
agent_dir="agents/$agent_name"
if [[ ! -d "$agent_dir" ]]; then
    echo "Agent not found: $agent_dir" >&2
    exit 1
fi

# Check for agent tools file (bash version)
agent_tools="$agent_dir/tools.sh"
if [[ ! -f "$agent_tools" ]]; then
    # Try to run the action as a regular tool
    bash scripts/run-tool.sh "$action" "$json_args"
    exit $?
fi

# Source the agent tools and call the action
source "$agent_tools"

# Convert JSON args to variables
if command -v jq >/dev/null 2>&1; then
    while IFS= read -r key; do
        value=$(echo "$json_args" | jq -r ".$key")
        if [[ "$value" != "null" ]]; then
            declare "arg_$key=$value"
        fi
    done < <(echo "$json_args" | jq -r 'keys[]')
fi

# Call the action function if it exists
if declare -f "$action" >/dev/null; then
    "$action"
else
    echo "Action not found: $action" >&2
    exit 1
fi