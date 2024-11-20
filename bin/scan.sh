#!/bin/bash

# Function to discover network routes
discover_routes() {
    # Use 'ip route' to list network routes
    ip route | awk '/src/ {print $1}'
}

# Function to scan a given network range
scan_network() {
    local network=$1
    echo "Scanning network: $network"
    # Use 'nmap' to scan the given network range
    nmap -sn $network
}

# Main function to discover and scan networks
main() {
    # Discover all network routes
    local routes=$(discover_routes)

    # Iterate over each discovered route and scan it
    for route in $routes; do
        scan_network $route
    done
}

# Execute the main function
main

