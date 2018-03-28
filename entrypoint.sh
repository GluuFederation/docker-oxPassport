#!/bin/sh

python /opt/scripts/entrypoint.py

cd /gluu-passport/server/
node app
