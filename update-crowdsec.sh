#!/usr/bin/env bash


CONTAINER_NAME="crowdsec"
DOCKER_BIN="/usr/bin/docker"
GREP_BIN="/usr/bin/grep"

# Check if container is running
if ! $DOCKER_BIN ps --format "table {{.Names}}" | $GREP_BIN -q "^${CONTAINER_NAME}$"; then
    echo "Container ${CONTAINER_NAME} is not running"
    exit 1
fi

# Update and check for upgrades
$DOCKER_BIN exec ${CONTAINER_NAME} cscli --error hub update >/dev/null
upgraded="$($DOCKER_BIN exec ${CONTAINER_NAME} cscli --error hub upgrade)"

if [ -n "$upgraded" ]; then
    echo "Hub updates detected, restarting container..."
    $DOCKER_BIN restart ${CONTAINER_NAME}
    echo "Container restarted successfully"
else
    echo "No hub updates available"
fi
