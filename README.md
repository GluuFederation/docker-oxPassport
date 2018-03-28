# docker-oxPassport
Docker version of the Gluu Passport implementation

Initial developmental build. Still in testing to determine functionality.

The user will have to map a volume on their local volume that will link to `/etc/gluu/conf/` inside the container.

Here they will need to have a properly configured `passport-saml-config.json`, as the script only. 
The entrypoint.py script automatically creates the `passport-config.json` from consul configurations.

All passport certificates can be found inside the container at `/etc/certs/`.
