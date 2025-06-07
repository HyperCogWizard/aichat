#!/usr/bin/env bash
set -e

# @describe Read file contents
# @option --path! The file path to read

main() {
    cat "$argc_path"
}

eval "$(argc --argc-eval "$0" "$@")"