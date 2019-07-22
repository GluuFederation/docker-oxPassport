#!/bin/sh

set -e

cat << LICENSE_ACK

# ================================================================================================ #
# Gluu License Agreement: https://github.com/GluuFederation/enterprise-edition/blob/4.0.0/LICENSE. #
# The use of Gluu Server Enterprise Edition is subject to the Gluu Support License.                #
# ================================================================================================ #

LICENSE_ACK

deps="config,secret"

if [ -f /etc/redhat-release ]; then
    source scl_source enable python27 && gluu-wait --deps="$deps"
else
    gluu-wait --deps="$deps"
fi

if [ ! -f /deploy/touched ]; then
    if [ -f /touched ]; then
        mv /touched /deploy/touched
    else
        if [ -f /etc/redhat-release ]; then
            source scl_source enable python27 && python /app/scripts/entrypoint.py
        else
            python /app/scripts/entrypoint.py
        fi

        touch /deploy/touched
    fi
fi

if [ -f /etc/redhat-release ]; then
    source scl_source enable rh-nodejs8 && node /opt/gluu/node/passport/server/app.js
else
    exec node /opt/gluu/node/passport/server/app.js
fi
