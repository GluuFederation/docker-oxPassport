#!/bin/sh

set -e

if [ -f /etc/redhat-release ]; then
    source scl_source enable python27 && python /opt/scripts/wait_for.py --deps="config,secret"
else
    python /opt/scripts/wait_for.py --deps="config,secret"
fi

if [ ! -f /deploy/touched ]; then
    if [ -f /touched ]; then
        mv /touched /deploy/touched
    else
        if [ -f /etc/redhat-release ]; then
            source scl_source enable python27 && python /opt/scripts/entrypoint.py
        else
            python /opt/scripts/entrypoint.py
        fi

        touch /deploy/touched
    fi
fi

if [ -f /etc/redhat-release ]; then
    source scl_source enable rh-nodejs8 && node /opt/gluu/node/passport/server/app.js
else
    exec node /opt/gluu/node/passport/server/app.js
fi
