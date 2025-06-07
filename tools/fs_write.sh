#!/usr/bin/env bash
set -e

# @describe Write text to a file
# @option --path! The file path to write to
# @option --content! The content to write

main() {
    echo "$argc_content" > "$argc_path"
    echo "File written successfully to $argc_path"
}

eval "$(argc --argc-eval "$0" "$@")"