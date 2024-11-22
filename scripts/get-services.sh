#!/bin/bash

SERVICES_INPUT=$1

if [ -z "$SERVICES_INPUT" ]; then
    echo "Usage: $0 <services_input>"
    exit 1
fi

if [ "$SERVICES_INPUT" = "all" ]; then
    # Find services with docker-compose.yml or docker-compose.yaml
    services=$(find . -type f \( -name "docker-compose.yml" -o -name "docker-compose.yaml" \) -not -path "*/\.*/*" -exec dirname {} \; | sed 's|^\./||')
else
    services="$SERVICES_INPUT"
fi

# Validate services were found
if [ -z "$services" ]; then
    echo "Error: No services found!"
    exit 1
fi

echo "$services"