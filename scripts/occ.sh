#!/bin/bash

# Default container name to operate on
container=${CONTAINER:-nextcloud}

show_help() {
    cat << EOF
$0: Run OCC commands in containers
Usage:
    $0 [PARAMS] [--] {OCC_PARAMS}

With PARAMS you can provide additional information to the script. The possible options are documented below.
The params in OCC_PARAMS are forwarded to the OCC script literally.

With double dash -- you can separate the params from the OCC params. This might be required if the names are recognized by both scripts.

Possible options for PARAMS:
  --help/-h      Print this help and exit
  --container C  Use the container named C to run the OCC command in

If the --container option is not given, the env variable CONTAINER will be checked. If this is not given, the default value is nextcloud.
Examples:

    $0 --container stable25 -- status
        Run the occ command "status" in the stable25 container
    
    $0 app:list
        List the apps in the default container (nextcloud)
EOF
}

run_occ() {
    docker compose exec --user www-data "$container" ./occ "$@"
    exit $?
}

while [ $# -gt 0 ]
do
    case "$1" in
        --container)
            container="$2"
            # Additional shift
            shift
            ;;
        --help|-h)
            show_help
            exit
            ;;
        --)
            shift
            run_occ "$@"
            ;;
        *)
            echo "Parameter $1 is not recognized. I assume this is for occ."
            run_occ "$@"
            ;;
    esac

    # Shift to the next parameter
    shift
done

echo "No command was given on the command line."
exit 1
