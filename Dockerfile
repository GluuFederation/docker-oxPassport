FROM node:10-alpine

# ===============
# Alpine packages
# ===============

RUN apk update \
    && apk add --no-cache py-pip shadow \
    && apk add --no-cache --virtual build-deps wget git

# ==========
# oxPassport
# ==========

ENV GLUU_VERSION=4.1.0 \
    GLUU_BUILD_DATE=2019-12-26 \
    NODE_MODULES_VERSION=version_4.1.0

RUN wget -q --no-check-certificate https://ox.gluu.org/npm/passport/passport-${GLUU_VERSION}.tgz -O /tmp/passport.tgz \
    && mkdir -p /opt/gluu/node/passport \
    && tar -xf /tmp/passport.tgz --strip-components=1 -C /opt/gluu/node/passport \
    && rm /tmp/passport.tgz

RUN wget -q --no-check-certificate https://ox.gluu.org/npm/passport/passport-${NODE_MODULES_VERSION}-node_modules.tar.gz -O /tmp/node_modules.tar.gz \
    && mkdir -p /opt/gluu/node/passport/node_modules \
    && tar -xf /tmp/node_modules.tar.gz --strip-components=1 -C /opt/gluu/node/passport/node_modules \
    && rm /tmp/node_modules.tar.gz

RUN ln -sf /usr/local/bin/node /usr/local/bin/nodejs \
    && cd /opt/gluu/node/passport \
    && npm install -P

# ====
# Tini
# ====

RUN wget -q --no-check-certificate https://github.com/krallin/tini/releases/download/v0.18.0/tini-static -O /usr/bin/tini \
    && chmod +x /usr/bin/tini

# ======
# Python
# ======

COPY requirements.txt /tmp/requirements.txt
RUN pip install -U pip \
    && pip install --no-cache-dir -r /tmp/requirements.txt

# =======
# Cleanup
# =======

RUN apk del build-deps \
    && rm -rf /var/cache/apk/*

# =======
# License
# =======

RUN mkdir -p /licenses
COPY LICENSE /licenses/

# ====
# misc
# ====

RUN mkdir -p /app \
    && mkdir -p /etc/certs \
    && mkdir -p /etc/gluu/conf \
    && mkdir -p /deploy

# ==========
# Config ENV
# ==========

ENV GLUU_CONFIG_ADAPTER=consul \
    GLUU_CONFIG_CONSUL_HOST=localhost \
    GLUU_CONFIG_CONSUL_PORT=8500 \
    GLUU_CONFIG_CONSUL_CONSISTENCY=stale \
    GLUU_CONFIG_CONSUL_SCHEME=http \
    GLUU_CONFIG_CONSUL_VERIFY=false \
    GLUU_CONFIG_CONSUL_CACERT_FILE=/etc/certs/consul_ca.crt \
    GLUU_CONFIG_CONSUL_CERT_FILE=/etc/certs/consul_client.crt \
    GLUU_CONFIG_CONSUL_KEY_FILE=/etc/certs/consul_client.key \
    GLUU_CONFIG_CONSUL_TOKEN_FILE=/etc/certs/consul_token \
    GLUU_CONFIG_KUBERNETES_NAMESPACE=default \
    GLUU_CONFIG_KUBERNETES_CONFIGMAP=gluu \
    GLUU_CONFIG_KUBERNETES_USE_KUBE_CONFIG=false

# ==========
# Secret ENV
# ==========

ENV GLUU_SECRET_ADAPTER=vault \
    GLUU_SECRET_VAULT_SCHEME=http \
    GLUU_SECRET_VAULT_HOST=localhost \
    GLUU_SECRET_VAULT_PORT=8200 \
    GLUU_SECRET_VAULT_VERIFY=false \
    GLUU_SECRET_VAULT_ROLE_ID_FILE=/etc/certs/vault_role_id \
    GLUU_SECRET_VAULT_SECRET_ID_FILE=/etc/certs/vault_secret_id \
    GLUU_SECRET_VAULT_CERT_FILE=/etc/certs/vault_client.crt \
    GLUU_SECRET_VAULT_KEY_FILE=/etc/certs/vault_client.key \
    GLUU_SECRET_VAULT_CACERT_FILE=/etc/certs/vault_ca.crt \
    GLUU_SECRET_KUBERNETES_NAMESPACE=default \
    GLUU_SECRET_KUBERNETES_SECRET=gluu \
    GLUU_SECRET_KUBERNETES_USE_KUBE_CONFIG=false

# ===========
# Generic ENV
# ===========

ENV NODE_LOGGING_DIR=/opt/gluu/node/passport/server/logs \
    PASSPORT_LOG_LEVEL=info \
    GLUU_WAIT_MAX_TIME=300 \
    GLUU_WAIT_SLEEP_DURATION=10

EXPOSE 8090

# ====
# misc
# ====

LABEL name="oxPassport" \
    maintainer="Gluu Inc. <support@gluu.org>" \
    vendor="Gluu Federation" \
    version="4.1.0" \
    release="dev" \
    summary="Gluu oxPassport" \
    description="Gluu interface to Passport.js to support social login and inbound identity"

COPY templates /app/templates
COPY scripts /app/scripts/
RUN chmod +x /app/scripts/entrypoint.sh

# # make node user as part of root group
# RUN usermod -a -G root node

# # adjust ownership
# RUN chown -R 1000:1000 /opt/gluu/node \
#     && chown -R 1000:1000 /deploy \
#     && chgrp -R 0 /opt/gluu/node && chmod -R g=u /opt/gluu/node \
#     && chgrp -R 0 /etc/certs && chmod -R g=u /etc/certs \
#     && chgrp -R 0 /etc/gluu && chmod -R g=u /etc/gluu \
#     && chgrp -R 0 /deploy && chmod -R g=u /deploy

# # run as non-root user
# USER 1000

ENTRYPOINT ["tini", "-g", "--"]
CMD ["/app/scripts/entrypoint.sh" ]
