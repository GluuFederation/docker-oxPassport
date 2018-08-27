#!/bin/sh

if [ ! -f /touched ]; then
    if [ -f /etc/redhat-release ]; then
        source scl_source enable python27 && python /opt/scripts/entrypoint.py
    else
        python /opt/scripts/entrypoint.py
    fi
    touch /touched
fi

if [ -f /etc/redhat-release ]; then
    source scl_source enable rh-nodejs8 && node /opt/gluu/node/passport/server/app.js
else
    exec node /opt/gluu/node/passport/server/app.js
fi
