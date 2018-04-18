# docker-oxPassport

Docker image packaging for oxPassport.

## Environment Variables

- `GLUU_KV_HOST`: host/IP address of Consul server
- `GLUU_KV_PORT`: port where Consul server is listening to
- `--add-host`: Hostname of Gluu Server

## Running Container

Here's an example on how to run the container:
```
docker run -d \
    --name oxpassport \
    -e GLUU_KV_HOST=$IPADDR \
    --add-host=${hostname}:$IPADDR \
    -p 8090:8090 \
    gluufederation/oxpassport:3.1.2_dev
```

## Thing to Know

Follow these [instructions to enable Passport](https://gluu.org/docs/ce/3.1.2/authn-guide/inbound-saml-passport/#enable-passport) in the Gluu Server.

Logs can be found at `/opt/gluu/node/passport/server/logs` inside the server, while also being available with the `docker logs -f <passport_container>` command.

Per the [Passport configuration](https://gluu.org/docs/ce/3.1.2/authn-guide/inbound-saml-passport/#configure-trust), you will need to edit the `passport-saml-config.json` file. It is located at `/etc/gluu/conf/passport-saml-config.json` inside the container. You will want to map a volume from host:container so that this configuration persists. For example:

```
docker run -d \
    --name oxpassport \
    -e GLUU_KV_HOST=$IPADDR \
    -v $PWD/etc/gluu/conf:/etc/gluu/conf \
    --add-host=${hostname}:$IPADDR \
    -p 8090:8090 \
    gluufederation/oxpassport:3.1.2_dev
```
