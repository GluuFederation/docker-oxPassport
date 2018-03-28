FROM openjdk:jre-alpine

LABEL maintainer="Gluu Inc. <support@gluu.org>"

# ===============
# Alpine packages
# ===============

RUN apk update && \
    apk add --update nodejs \
    nodejs-npm \
    python \
    git && \
    git clone https://github.com/GluuFederation/gluu-passport.git && \
    cd gluu-passport &&\ 
    npm install && \
    ln -s /usr/local/bin/node /usr/local/bin/nodejs && \
    cd /usr/lib/jvm && ln -s java-1.8.0-openjdk-amd64 default-java && \
    pip install -U pip "consulate==0.6.0" pyDes

RUN mkdir -p /opt/scripts && \
    mkdir -p /etc/certs && \
    mkdir -p /etc/gluu/conf

ENV GLUU_LDAP_URL localhost:1636
ENV GLUU_KV_HOST localhost
ENV GLUU_KV_PORT 8500

EXPOSE 8090

VOLUME /gluu-passport/server/
VOLUME /etc/gluu/conf/

COPY entrypoint.sh /opt/scripts/
COPY entrypoint.py /opt/scripts/
COPY examples/passport-config.json /etc/gluu/conf/
COPY templates/passport-saml-config.json.tmpl /tmp/
RUN chmod +x /opt/scripts/entrypoint.sh
CMD [ "/opt/scripts/entrypoint.sh" ]
