module "starrocks_ca" {
  source      = "../ca"
  common_name = "starrocks"
}

resource "local_file" "starrocks_ca_cert" {
  content         = module.starrocks_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/starrocks-ca.crt"
}

resource "local_file" "starrocks_ca_key" {
  content         = module.starrocks_ca.key
  file_permission = "0600"
  filename        = "${path.module}/../shared/starrocks-ca.key"
}


resource "tls_private_key" "starrocks_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "starrocks_request" {
  private_key_pem = tls_private_key.starrocks_key.private_key_pem

  subject {
    common_name = "starrocks-server"
  }

  dns_names = ["*.ferlab.lan"]
}

resource "tls_locally_signed_cert" "starrocks_certificate" {
  cert_request_pem      = tls_cert_request.starrocks_request.cert_request_pem
  ca_private_key_pem    = module.starrocks_ca.key
  ca_cert_pem           = module.starrocks_ca.certificate

  validity_period_hours = 100*365*24
  early_renewal_hours   = 365*24

  allowed_uses = [
    "server_auth",
  ]

  is_ca_certificate = false
}

resource "local_file" "starrocks_cert" {
  content         = tls_locally_signed_cert.starrocks_certificate.cert_pem
  file_permission = "0600"
  filename        = "${path.module}/../shared/starrocks.crt"
}

resource "local_file" "starrocks_key" {
  content         = tls_private_key.starrocks_key.private_key_pem
  file_permission = "0600"
  filename        = "${path.module}/../shared/starrocks.key"
}

resource "null_resource" "starrocks_pkcs12_from_pem" {
  triggers = {
    cert    = sensitive(sha256(local_file.starrocks_cert.content))
    key     = sensitive(sha256(local_file.starrocks_key.content))
    passout = sensitive(local.params.starrocks.ssl_keystore_password)
    passin  = sensitive(local.params.starrocks.ssl_key_password)
  }

  provisioner "local-exec" {
    command = "openssl pkcs12 -export -in ${local_file.starrocks_cert.filename} -inkey ${local_file.starrocks_key.filename} -out ${path.module}/../shared/starrocks.p12 -passout pass:${local.params.starrocks.ssl_keystore_password} -passin pass:${local.params.starrocks.ssl_key_password}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm ${path.module}/../shared/starrocks.p12"
  }
}

data "local_file" "starrocks_pkcs12_from_pem" {
  filename = "${path.module}/../shared/starrocks.p12"

  depends_on = [null_resource.starrocks_pkcs12_from_pem]
}
