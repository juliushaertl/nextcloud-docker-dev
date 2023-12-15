#!/usr/bin/env bash

set -e
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
# shellcheck source=example.env
source "${SCRIPT_DIR}/../.env"
# shellcheck source=scripts/functions.sh
source "${SCRIPT_DIR}/functions.sh"

function OCC () {
    docker_compose exec nextcloud sudo -E -u www-data "./occ" "$@"
}

OCC config:system:set enabledPreviewProviders 0 --value 'OC\Preview\MP3'
OCC config:system:set enabledPreviewProviders 1 --value 'OC\Preview\TXT'
OCC config:system:set enabledPreviewProviders 2 --value 'OC\Preview\MarkDown'
OCC config:system:set enabledPreviewProviders 3 --value 'OC\Preview\OpenDocument'
OCC config:system:set enabledPreviewProviders 4 --value 'OC\Preview\Krita'
OCC config:system:set enabledPreviewProviders 5 --value 'OC\Preview\Imaginary'

OCC config:system:set preview_imaginary_url --value 'http://previews_hpb:8088'
