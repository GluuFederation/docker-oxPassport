#!/bin/sh

set -e

run_wait() {
    python /app/scripts/wait.py
}

run_entrypoint() {
    if [ ! -f /deploy/touched ]; then
        python /app/scripts/entrypoint.py
        touch /deploy/touched
    fi
}

run_wait
run_entrypoint

exec node /opt/gluu/node/passport/server/app.js
