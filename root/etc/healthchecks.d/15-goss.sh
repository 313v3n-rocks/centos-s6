#!/usr/bin/with-contenv bash
cd /etc/healthchecks.d/

if [[ -f goss.yaml ]]; then
 goss validate
fi
