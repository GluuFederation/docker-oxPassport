FROM node:10-alpine

LABEL maintainer="Gluu Inc. <support@gluu.org>"

# ===============
# Alpine packages
# ===============

RUN apk update && apk add --no-cache --update \
    wget \
    py-pip \
    shadow

# ==========
# oxPassport
# ==========
ENV OX_VERSION 4.0.0
ENV OX_BUILD_DATE 2019-06-24

RUN wget -q --no-check-certificate https://ox.gluu.org/npm/passport/passport-${OX_VERSION}.tgz -O /tmp/passport.tgz \
    && mkdir -p /opt/gluu/node/passport \
    && tar -xf /tmp/passport.tgz --strip-components=1 -C /opt/gluu/node/passport \
    && rm /tmp/passport.tgz \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
    && cd /opt/gluu/node/passport \
    && npm install

# ====
# Tini
# ====

ENV TINI_VERSION v0.18.0
RUN wget -q --no-check-certificate https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static -O /usr/bin/tini \
    && chmod +x /usr/bin/tini

# ======
# Python
# ======

COPY requirements.txt /tmp/requirements.txt
RUN pip install -U pip \
    && pip install --no-cache-dir -r /tmp/requirements.txt

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

ENV GLUU_CONFIG_ADAPTER consul
ENV GLUU_CONFIG_CONSUL_HOST localhost
ENV GLUU_CONFIG_CONSUL_PORT 8500
ENV GLUU_CONFIG_CONSUL_CONSISTENCY stale
ENV GLUU_CONFIG_CONSUL_SCHEME http
ENV GLUU_CONFIG_CONSUL_VERIFY false
ENV GLUU_CONFIG_CONSUL_CACERT_FILE /etc/certs/consul_ca.crt
ENV GLUU_CONFIG_CONSUL_CERT_FILE /etc/certs/consul_client.crt
ENV GLUU_CONFIG_CONSUL_KEY_FILE /etc/certs/consul_client.key
ENV GLUU_CONFIG_CONSUL_TOKEN_FILE /etc/certs/consul_token
ENV GLUU_CONFIG_KUBERNETES_NAMESPACE default
ENV GLUU_CONFIG_KUBERNETES_CONFIGMAP gluu
ENV GLUU_CONFIG_KUBERNETES_USE_KUBE_CONFIG false

# ==========
# Secret ENV
# ==========

ENV GLUU_SECRET_ADAPTER vault
ENV GLUU_SECRET_VAULT_SCHEME http
ENV GLUU_SECRET_VAULT_HOST localhost
ENV GLUU_SECRET_VAULT_PORT 8200
ENV GLUU_SECRET_VAULT_VERIFY false
ENV GLUU_SECRET_VAULT_ROLE_ID_FILE /etc/certs/vault_role_id
ENV GLUU_SECRET_VAULT_SECRET_ID_FILE /etc/certs/vault_secret_id
ENV GLUU_SECRET_VAULT_CERT_FILE /etc/certs/vault_client.crt
ENV GLUU_SECRET_VAULT_KEY_FILE /etc/certs/vault_client.key
ENV GLUU_SECRET_VAULT_CACERT_FILE /etc/certs/vault_ca.crt
ENV GLUU_SECRET_KUBERNETES_NAMESPACE default
ENV GLUU_SECRET_KUBERNETES_SECRET gluu
ENV GLUU_SECRET_KUBERNETES_USE_KUBE_CONFIG false

# ===========
# Generic ENV
# ===========

ENV NODE_LOGGING_DIR /opt/gluu/node/passport/server/logs
ENV GLUU_WAIT_MAX_TIME 300
ENV GLUU_WAIT_SLEEP_DURATION 5

EXPOSE 8090

COPY templates /app/templates
COPY scripts /app/scripts/

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
CMD ["sh", "/app/scripts/entrypoint.sh" ]
