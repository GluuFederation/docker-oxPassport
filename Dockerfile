FROM node:alpine

LABEL maintainer="Gluu Inc. <support@gluu.org>"

# ===============
# Alpine packages
# ===============

RUN apk update && \
    apk add --no-cache --update \
    python \
    wget \
    py-pip && \
    pip install --no-cache-dir pip "consulate==0.6.0" pyDes && \
    ln -s /usr/local/bin/node /usr/local/bin/nodejs&& \
    wget --no-check-certificate https://ox.gluu.org/npm/passport/passport-3.1.3.tgz && \
    tar -xf passport-3.1.3.tgz && \
    cd /package/ && \
    npm install

RUN mkdir -p /opt/scripts && \
    mkdir -p /etc/certs && \
    mkdir -p /etc/gluu/conf

ENV GLUU_KV_HOST localhost
ENV GLUU_KV_PORT 8500

EXPOSE 8090

VOLUME /etc/gluu/conf/

COPY entrypoint.sh /opt/scripts/
COPY entrypoint.py /opt/scripts/
COPY passport-config.json.tmpl /tmp/
COPY passport-saml-config.json /etc/gluu/conf/

RUN chmod +x /opt/scripts/entrypoint.sh

CMD [ "/opt/scripts/entrypoint.sh" ]
