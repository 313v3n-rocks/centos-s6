#!/usr/bin/with-contenv bash
#
# This script will return 0 if all services are ok
#

for f in /var/run/s6/services/*; do
    if [[ -d $f ]]; then
        status=$(s6-svstat -o up,wantedup $f)

        if [ "$status" == "true true" ] || [ "$status" == "false false" ]; then
            continue
        fi

        echo "Service $f is not in desired state: $status"
        exit 1
    fi
done
