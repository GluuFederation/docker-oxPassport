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

COPY requirements.txt /tmp/requirements.txt
RUN pip install -U pip \
    && pip install --no-cache-dir -r /tmp/requirements.txt

# ====
# misc
# ====

RUN mkdir -p /opt/scripts && \
    mkdir -p /etc/certs && \
    mkdir -p /etc/gluu/conf

ENV NODE_LOGGING_DIR /opt/gluu/node/passport/server/logs

EXPOSE 8090

VOLUME /etc/gluu/conf/

COPY entrypoint.sh /opt/scripts/
COPY entrypoint.py /opt/scripts/
COPY passport-config.json.tmpl /tmp/
COPY passport-saml-config.json /etc/gluu/conf/
COPY logger.js /opt/gluu/node/passport/server/utils/
COPY wait-for-it /opt/scripts/
COPY gluu_config.py /opt/scripts

RUN chmod +x /opt/scripts/entrypoint.sh

CMD ["/opt/scripts/wait-for-it", "/opt/scripts/entrypoint.sh" ]
