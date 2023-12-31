#!/usr/bin/env bash

set -e
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
# shellcheck source=example.env
source "${SCRIPT_DIR}/../.env"
# shellcheck source=scripts/functions.sh
source "${SCRIPT_DIR}/functions.sh"

if [ -z "$1" ]
  then
    echo "Usage $0 CONTAINER"
	exit 1
fi

CONTAINER=$1

function occ() {
    docker_compose exec "$CONTAINER" sudo -E -u www-data "./occ" "$@"
}

echo "Setting up talk signaling with ${PROTOCOL:-http}://talk-signaling$DOMAIN_SUFFIX on $CONTAINER"
docker_compose up -d talk-signaling talk-janus

if ! occ talk:signaling:list --output="plain" | grep -q "${PROTOCOL:-http}://talk-signaling$DOMAIN_SUFFIX"; then
  occ talk:signaling:add "${PROTOCOL:-http}://talk-signaling$DOMAIN_SUFFIX" "1234"
fi

