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
