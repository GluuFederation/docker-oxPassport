#!/usr/bin/python

import os
import consulate
import base64
from pyDes import triple_des, PAD_PKCS5

GLUU_KV_HOST = os.environ.get("GLUU_KV_HOST", "localhost")
GLUU_KV_PORT = os.environ.get("GLUU_KV_PORT", 8500)
consul = consulate.Consul(host=GLUU_KV_HOST, port=GLUU_KV_PORT)


def unobscure(s=""):
    cipher = triple_des(b"{}".format(consul.kv.get("gluu/config/encoded_salt")))
    decrypted = cipher.decrypt(base64.b64decode(s), padmode=PAD_PKCS5)
    return decrypted


def writeCerts(cert_fn, cert):
    with open(cert_fn, 'w') as file_:
        file_.write(cert)


if __name__ == "__main__":
    hostname = consul.kv.get("gluu/config/hostname")
    passport_rp_client_id = consul.kv.get("gluu/config/passport_rp_client_id")
    passport_rp_client_cert_fn = consul.kv.get("gluu/config/passport_rp_client_cert_fn")
    passport_rp_client_cert_base64 = consul.kv.get("gluu/config/passport_rp_client_cert_base64")
    passport_rp_client_cert = unobscure(b"{}".format(passport_rp_client_cert_base64))
    passport_rp_client_cert_alias = consul.kv.get("gluu/config/passport_rp_client_cert_alias")
    passport_rp_client_cert_alg = consul.kv.get("gluu/config/passport_rp_client_cert_alg")

    passport_rp_jks_base64 = consul.kv.get("gluu/config/passport_rp_jks_base64")
    passport_rp_client_jks_fn = consul.kv.get("gluu/config/passport_rp_client_jks_fn")
    passport_rp_jks = unobscure(b"{}".format(passport_rp_jks_base64))

    passport_sp_cert_base64 = consul.kv.get("gluu/config/passport_sp_cert_base64")
    passport_sp_key_base64 = consul.kv.get("gluu/config/passport_sp_key_base64")
    passport_sp_cert = unobscure(b"{}".format(passport_sp_cert_base64))
    passport_sp_key = unobscure(b"{}".format(passport_sp_key_base64))

    passport_rs_jks_base64 = consul.kv.get("gluu/config/passport_rs_jks_base64")
    passport_rs_jks = unobscure(b"{}".format(passport_rs_jks_base64))
    passport_rs_client_jks_fn = consul.kv.get("gluu/config/passport_rs_client_jks_fn")

    idpSigningCert = consul.kv.get("gluu/config/idp3SigningCertificateText")

    certs = {
        passport_rs_client_jks_fn: passport_rs_jks,
        passport_rp_client_jks_fn: passport_rp_jks,
        passport_rp_client_cert_fn: passport_rp_client_cert,
        '/etc/certs/idp-signing.crt': idpSigningCert,
        '/etc/certs/passport-sp.crt': passport_sp_cert,
        '/etc/certs/passport-sp.key': passport_sp_key,
    }

    config = {
        '%hostname': hostname,
        '%passport_rp_client_id': passport_rp_client_id,
        '%passport_rp_client_cert_fn': passport_rp_client_cert_fn,
        '%passport_rp_client_cert_alias': passport_rp_client_cert_alias,
        '%passport_rp_client_cert_alg': passport_rp_client_cert_alg,
        '%idpSigningCert': idpSigningCert,
    }

    # Automatically create passport-config.json from entries
    with open('/tmp/passport-config.json.tmpl', 'r') as file_:
        data = file_.read()

    for k, v in config.iteritems():
        data = data.replace(k, v)

    with open('/etc/gluu/conf/passport-config.json', 'w') as file_:
        file_.write(data)

    # Write necessary certificates to file
    for cert_fn, cert in certs.iteritems():
        writeCerts(cert_fn, cert)
