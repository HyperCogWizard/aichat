#!/usr/bin/env bash
set -e

# @describe Get current weather information for a location.
# @option --location! The location to get weather for.

# @env OPENWEATHERMAP_API_KEY! Required for weather API access

main() {
    if [[ -z "$OPENWEATHERMAP_API_KEY" ]]; then
        echo "Error: OPENWEATHERMAP_API_KEY environment variable not set" >&2
        return 1
    fi
    
    curl -s "http://api.openweathermap.org/data/2.5/weather?q=${argc_location}&appid=${OPENWEATHERMAP_API_KEY}&units=metric" \
        | jq -r '.name + ": " + .weather[0].description + ", " + (.main.temp|tostring) + "°C"'
}

eval "$(argc --argc-eval "$0" "$@")"