#!/bin/bash

# Function to parse YAML file and extract endpoints
parse_config() {
    local config_file="$1"
    yq eval '.endpoints[]' "$config_file" | while read -r endpoint; do
        name=$(echo "$endpoint" | yq e '.name')
        url=$(echo "$endpoint" | yq e '.url')
        headers=$(echo "$endpoint" | yq e '.headers // ""')
        body=$(echo "$endpoint" | yq e '.body // ""')
        echo "$name,$url,$headers,$body"
    done
}

# Function to send HTTP request and determine status
check_endpoint() {
    local name="$1"
    local url="$2"
    local headers="$3"
    local body="$4"

    local curl_cmd="curl -s -o /dev/null --write-out '%{http_code},%{time_total}'"

    if [ "$headers" != "" ]; then
        while IFS=':' read key value; do
            curl_cmd+=" -H '$key: $value'"
        done <<< "$headers"
    fi

    if [ "$body" != "" ]; then
        curl_cmd+=" -d '$body'"
    fi

    curl_cmd+=" '$url'"

    result=$(eval "$curl_cmd")
    http_code=$(echo "$result" | cut -d, -f1)
    time_total=$(echo "$result" | cut -d, -f2)

    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ] && (( $(echo "$time_total < 0.5") )); then
        echo "UP"
    else
        echo "DOWN"
    fi
}

# Function to extract domain from URL
get_domain() {
    local url="$1"
    # Remove http:// or https:// and path, get the domain part
    domain=$(echo "$url" | sed -e 's,^https*://,,; s,/.*$,,' )
    echo "$domain"
}

# Initialize counters
declare -A check_sum
declare -A up_tally

config_file="endpoints.yaml"

# Parse the configuration file once to get all endpoints
parse_config "$config_file" > endpoints.txt

trap 'exit 0' SIGINT # Handle Ctrl+C gracefully

while true; do
    while IFS=, read name url headers body; do
        status=$(check_endpoint "$name" "$url" "$headers" "$body")
        domain=$(get_domain "$url")

        check_sum[$domain]=$(( ${check_sum[$domain]:-0} + 1 ))

        if [ "$status" == "UP" ]; then
            up_tally[$domain]=$(( ${up_tally[$domain]:-0} + 1 ))
        fi
    done < endpoints.txt

    # Log the results for each domain
    echo -e "\nCurrent availability status:"
    for domain in "${!check_sum[@]}"; do
        total=${check_sum[$domain]}
        up=${up_tally[$domain]}
        if [ "$total" -eq 0 ]; then
            percentage=0
        else
            percentage=$(( (up * 100) / total ))
        fi
        echo -e "\t$domain: $percentage%"
    done

    # Sleep for 15 seconds before next check
    sleep 15
done
