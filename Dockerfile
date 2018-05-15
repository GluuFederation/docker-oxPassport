FROM node:alpine

LABEL maintainer="Gluu Inc. <support@gluu.org>"

# ===============
# Alpine packages
# ===============

RUN apk update && apk add --no-cache --update \
    wget \
    py-pip

# ==========
# oxPassport
# ==========
ENV OX_VERSION 3.1.3

RUN wget -q --no-check-certificate https://ox.gluu.org/npm/passport/passport-${OX_VERSION}.tgz -O /tmp/passport.tgz \
    && mkdir -p /opt/gluu/node/passport \
    && tar -xf /tmp/passport.tgz --strip-components=1 -C /opt/gluu/node/passport \
    && rm /tmp/passport.tgz \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
    && cd /opt/gluu/node/passport \
    && npm install

# ======
# Python
# ======

RUN pip install --no-cache-dir -U pip \
    && pip install "consulate==0.6.0" pyDes

RUN mkdir -p /opt/scripts && \
    mkdir -p /etc/certs && \
    mkdir -p /etc/gluu/conf

ENV GLUU_KV_HOST localhost
ENV GLUU_KV_PORT 8500
ENV NODE_LOGGING_DIR /opt/gluu/node/passport/server/logs

EXPOSE 8090

VOLUME /etc/gluu/conf/

COPY entrypoint.sh /opt/scripts/
COPY entrypoint.py /opt/scripts/
COPY passport-config.json.tmpl /tmp/
COPY passport-saml-config.json /etc/gluu/conf/
COPY logger.js /opt/gluu/node/passport/server/utils/
COPY wait-for-it /opt/scripts/

RUN chmod +x /opt/scripts/entrypoint.sh

CMD ["/opt/scripts/wait-for-it", "/opt/scripts/entrypoint.sh" ]
