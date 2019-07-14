import os
import re
# import shutil

from pygluu.containerlib import get_manager


# def copy_static_templates():
#     """Copies static templates (default) to /etc/gluu/conf directories.

#     Prior to v3.1.5, `/etc/gluu/conf` is defined as VOLUME which cause issue
#     in some of orchestrator (i.e. docker-compose) when switching image from
#     older version to v3.1.5, as the volume is preserved and requires
#     a full re-deploy of the container.

#     This operation is safe because it checks for non-existing file first before
#     copying the template, hence any mounted file will be left intact.
#     """
#     templates = [
#         "passport-saml-config.json",
#         "passport-inbound-idp-initiated.json",
#     ]

#     for template in templates:
#         src = "/app/templates/{}".format(template)
#         dst = "/etc/gluu/conf/{}".format(template)
#         if not os.path.exists(dst):
#             shutil.copyfile(src, dst)


def sync_jks(manager):
    # render passport-rp.jks
    manager.secret.to_file(
        "passport_rp_jks_base64",
        manager.config.get("passport_rp_client_jks_fn"),
        decode=True,
        binary_mode=True,
    )

    # render passport-rs.jks
    manager.secret.to_file(
        "passport_rs_jks_base64",
        manager.config.get("passport_rs_client_jks_fn"),
        decode=True,
        binary_mode=True,
    )


def sync_certs(manager):
    # render passport-rp.crt
    manager.secret.to_file(
        "passport_rp_client_cert_base64",
        manager.config.get("passport_rp_client_cert_fn"),
        decode=True,
    )

    # render idp-signing.crt
    manager.secret.to_file("idp3SigningCertificateText",
                           "/etc/certs/idp-signing.crt")

    # render passport-sp.crt
    manager.secret.to_file("passport_sp_cert_base64",
                           "/etc/certs/passport-sp.crt",
                           decode=True)

    # render passport-sp.key
    manager.secret.to_file("passport_sp_key_base64",
                           "/etc/certs/passport-sp.key",
                           decode=True)


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
    sync_jks(manager)
    sync_certs(manager)
    render_passport_config(manager)
    # copy_static_templates()


if __name__ == "__main__":
    main()
