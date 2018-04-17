#!/bin/sh

if [ ! -f /touched ]; then
    python /opt/scripts/entrypoint.py
    touch /touched
fi

exec node /opt/gluu/node/passport/server/app.js
