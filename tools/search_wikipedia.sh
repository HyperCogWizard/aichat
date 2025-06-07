#!/usr/bin/env bash
set -e

# @describe Search Wikipedia for information
# @option --query! The search query

main() {
    query=$(echo "$argc_query" | tr ' ' '+')
    
    # Use Wikipedia API to search
    result=$(curl -s "https://en.wikipedia.org/api/rest_v1/page/summary/${query}" | jq -r '.extract // "No information found"')
    
    echo "Wikipedia search result for '$argc_query':"
    echo "$result"
}

eval "$(argc --argc-eval "$0" "$@")"