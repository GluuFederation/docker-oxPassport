# docker-oxPassport

Docker image packaging for oxPassport.

## Latest Stable Release

The latest stable release is `gluufederation/oxpassport:3.1.3_02`. Click [here](./CHANGES.md) for archived versions.

## Versioning/Tagging

This image uses its own versioning/tagging format.

    <IMAGE-NAME>:<GLUU-SERVER-VERSION>_<RELEASE_VERSION>

For example, `gluufederation/oxpassport:3.1.3_02` consists of:

- `gluufederation/oxpassport` as `<IMAGE_NAME>`: the actual image name
- `3.1.3` as `GLUU-SERVER-VERSION`: the Gluu Server version as setup reference
- `02` as `<RELEASE_VERSION>`

## Installation

Pull the image:

    docker pull gluufederation/oxpassport:3.1.3_02

## Environment Variables

- `GLUU_CONFIG_ADAPTER`: config backend (either `consul` for Consul KV or `kubernetes` for Kubernetes configmap)

The following environment variables are activated only if `GLUU_CONFIG_ADAPTER` is set to `consul`:

- `GLUU_CONSUL_HOST`: hostname or IP of Consul (default to `localhost`)
- `GLUU_CONSUL_PORT`: port of Consul (default to `8500`)
- `GLUU_CONSUL_CONSISTENCY`: Consul consistency mode (choose one of `default`, `consistent`, or `stale`). Default to `stale` mode.

otherwise, if `GLUU_CONFIG_ADAPTER` is set to `kubernetes`:

- `GLUU_KUBERNETES_NAMESPACE`: Kubernetes namespace (default to `default`)
- `GLUU_KUBERNETES_CONFIGMAP`: Kubernetes configmap name (default to `gluu`)

## Running Container

Here's an example on how to run the container:
```
docker run -d \
    --name oxpassport \
    -e GLUU_CONSUL_HOST=consul.example.com \
    -p 8090:8090 \
    gluufederation/oxpassport:3.1.3_02
```

## Thing to Know

Follow these [instructions to enable Passport](https://gluu.org/docs/ce/3.1.3/authn-guide/inbound-saml-passport/#enable-passport) in the Gluu Server.

Logs can be found at `/opt/gluu/node/passport/server/logs` inside the server, while also being available with the `docker logs -f <passport_container>` command.

Per the [Passport configuration](https://gluu.org/docs/ce/3.1.3/authn-guide/inbound-saml-passport/#configure-trust), you will need to edit the `passport-saml-config.json` file. It is located at `/etc/gluu/conf/passport-saml-config.json` inside the container. You will want to map a volume from host:container so that this configuration persists. For example:

```
docker run -d \
    --name oxpassport \
    -e GLUU_CONSUL_HOST=consul.example.com \
    -v /host/path/to/conf:/etc/gluu/conf \
    -p 8090:8090 \
    gluufederation/oxpassport:3.1.3_02
```

Be aware that you should already have a `passport-saml-config.json` located where you point the `-v /host/path/to/conf/:/etc/gluu/conf \`, otherwise start-up will fail.
