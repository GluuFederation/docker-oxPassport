import base64
# import os
import re
# import shutil

from pyDes import triple_des, PAD_PKCS5

from gluulib import get_manager

manager = get_manager()


def unobscure(s=""):
    cipher = triple_des(b"{}".format(manager.secret.get("encoded_salt")))
    decrypted = cipher.decrypt(base64.b64decode(s), padmode=PAD_PKCS5)
    return decrypted


def writeCerts(cert_fn, cert):
    with open(cert_fn, 'w') as file_:
        file_.write(cert)


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


if __name__ == "__main__":
    hostname = manager.config.get("hostname")
    passport_rp_client_id = manager.config.get("passport_rp_client_id")
    passport_rp_client_cert_fn = manager.config.get("passport_rp_client_cert_fn")
    passport_rp_client_cert_base64 = manager.secret.get("passport_rp_client_cert_base64")
    passport_rp_client_cert = unobscure(b"{}".format(passport_rp_client_cert_base64))
    passport_rp_client_cert_alias = manager.config.get("passport_rp_client_cert_alias")
    passport_rp_client_cert_alg = manager.config.get("passport_rp_client_cert_alg")

    passport_rp_jks_base64 = manager.secret.get("passport_rp_jks_base64")
    passport_rp_client_jks_fn = manager.config.get("passport_rp_client_jks_fn")
    passport_rp_jks = unobscure(b"{}".format(passport_rp_jks_base64))

    passport_sp_cert_base64 = manager.secret.get("passport_sp_cert_base64")
    passport_sp_key_base64 = manager.secret.get("passport_sp_key_base64")
    passport_sp_cert = unobscure(b"{}".format(passport_sp_cert_base64))
    passport_sp_key = unobscure(b"{}".format(passport_sp_key_base64))

    passport_rs_jks_base64 = manager.secret.get("passport_rs_jks_base64")
    passport_rs_jks = unobscure(b"{}".format(passport_rs_jks_base64))
    passport_rs_client_jks_fn = manager.config.get("passport_rs_client_jks_fn")

    idpSigningCert = manager.secret.get("idp3SigningCertificateText")

    certs = {
        passport_rs_client_jks_fn: passport_rs_jks,
        passport_rp_client_jks_fn: passport_rp_jks,
        passport_rp_client_cert_fn: passport_rp_client_cert,
        '/etc/certs/idp-signing.crt': idpSigningCert,
        '/etc/certs/passport-sp.crt': passport_sp_cert,
        '/etc/certs/passport-sp.key': passport_sp_key,
    }

    config = {
        'hostname': hostname,
        'passport_rp_client_id': passport_rp_client_id,
        'passport_rp_client_cert_fn': passport_rp_client_cert_fn,
        'passport_rp_client_cert_alias': passport_rp_client_cert_alias,
        'passport_rp_client_cert_alg': passport_rp_client_cert_alg,
        'idpSigningCert': idpSigningCert,
    }

    # Automatically create passport-config.json from entries
    with open('/app/templates/passport-config.json.tmpl', 'r') as file_:
        data = file_.read() % config

        # ensure logs emitted to stdout
        data = re.sub(r'("consoleLogOnly": )false', r"\1true", data, flags=re.DOTALL | re.M)

        with open('/etc/gluu/conf/passport-config.json', 'w') as file_:
            file_.write(data)

    # Write necessary certificates to file
    for cert_fn, cert in certs.iteritems():
        writeCerts(cert_fn, cert)

    # copy_static_templates()
