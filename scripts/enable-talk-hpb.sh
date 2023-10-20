#!/usr/bin/env bash

if [ -z "$1" ]
  then
    echo "Usage $0 CONTAINER"
	exit 1
fi

CONTAINER=$1

function occ() {
    docker compose exec "$CONTAINER" sudo -E -u www-data "./occ" "$@"
}

# shellcheck disable=SC1091
source .env

echo "Setting up talk signaling with http://talk-signaling$DOMAIN_SUFFIX on $CONTAINER"
if docker compose up -d talk-signaling talk-janus 2>/dev/null; then
    :
else
    docker-compose up -d talk-signaling talk-janus
fi

if ! occ talk:signaling:list --output="plain" | grep -q "http://talk-signaling$DOMAIN_SUFFIX"; then
  occ talk:signaling:add "http://talk-signaling$DOMAIN_SUFFIX" "1234"
fi

