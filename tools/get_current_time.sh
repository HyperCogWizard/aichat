#!/usr/bin/env bash
set -e

# @describe Get current time
# @option --format=%Y-%m-%d %H:%M:%S Format

main() {
    date +"$argc_format"
}

eval "$(argc --argc-eval "$0" "$@")"