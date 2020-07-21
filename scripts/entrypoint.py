import os
import re

from pygluu.containerlib import get_manager
from pygluu.containerlib.persistence import render_salt


def render_passport_config(manager):
    config = {
        'hostname': manager.config.get("hostname"),
        'passport_rp_client_id': manager.config.get("passport_rp_client_id"),
        'passport_rp_client_cert_fn': manager.config.get("passport_rp_client_cert_fn"),
        'passport_rp_client_cert_alias': manager.config.get("passport_rp_client_cert_alias"),
        'passport_rp_client_cert_alg': manager.config.get("passport_rp_client_cert_alg"),
        "idpSigningCert": manager.secret.get("idp3SigningCertificateText"),
    }

    # Automatically create passport-config.json from entries
    with open('/app/templates/passport-config.json.tmpl', 'r') as file_:
        data = file_.read() % config

        # ensure logs emitted to stdout
        data = re.sub(r'("consoleLogOnly": )false', r"\1true", data, flags=re.DOTALL | re.M)

        log_level = os.environ.get("PASSPORT_LOG_LEVEL", "info")
        # changing log level
        data = re.sub(r'("logLevel": )"info"', r'\1"{}"'.format(log_level), data, flags=re.DOTALL | re.M)

        with open('/etc/gluu/conf/passport-config.json', 'w') as file_:
            file_.write(data)


def main():
    manager = get_manager()

    manager.secret.to_file(
        "passport_rp_jks_base64",
        manager.config.get("passport_rp_client_jks_fn"),
        decode=True,
        binary_mode=True,
    )
    manager.secret.to_file(
        "passport_rs_jks_base64",
        manager.config.get("passport_rs_client_jks_fn"),
        decode=True,
        binary_mode=True,
    )
    manager.secret.to_file(
        "passport_rp_client_cert_base64",
        manager.config.get("passport_rp_client_cert_fn"),
        decode=True,
    )
    manager.secret.to_file("idp3SigningCertificateText", "/etc/certs/idp-signing.crt")
    manager.secret.to_file("passport_sp_cert_base64", "/etc/certs/passport-sp.crt", decode=True)
    manager.secret.to_file("passport_sp_key_base64", "/etc/certs/passport-sp.key", decode=True)

    render_passport_config(manager)
    render_salt(manager, "/app/templates/salt.tmpl", "/etc/gluu/conf/salt")
    # copy_static_templates()


if __name__ == "__main__":
    main()
