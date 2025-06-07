#!/usr/bin/env bash
set -e

# @describe Fetch web page content via curl
# @option --url! The URL to fetch

main() {
    # Fetch the URL with curl
    content=$(curl -s -L "$argc_url" || echo "Failed to fetch URL")
    
    # Output the content
    echo "Content from $argc_url:"
    echo "$content"
}

eval "$(argc --argc-eval "$0" "$@")"