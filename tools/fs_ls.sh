#!/usr/bin/env bash
set -e

# @describe List files and directories
# @option --path=. The path to list

main() {
    ls -la "$argc_path"
}

eval "$(argc --argc-eval "$0" "$@")"