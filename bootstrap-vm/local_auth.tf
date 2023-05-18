module "bootstrap_ca" {
  source = "../ca"
  common_name = "bootstrap"
}

resource "tls_private_key" "bootstrap" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "tls_cert_request" "bootstrap" {
  private_key_pem = tls_private_key.bootstrap.private_key_pem
  subject {
    common_name  = "bootstrap"
    organization = "Ferlab"
  }
  ip_addresses   = ["127.0.0.10"]
}

resource "tls_locally_signed_cert" "bootstrap" {
  cert_request_pem   = tls_cert_request.bootstrap.cert_request_pem
  ca_private_key_pem = module.bootstrap_ca.key
  ca_cert_pem        = module.bootstrap_ca.certificate

  validity_period_hours = 365 * 24
  early_renewal_hours = 14 * 24

  allowed_uses = [
    "client_auth",
    "server_auth",
  ]

  is_ca_certificate = false
}

resource "random_password" "terraform_backend_etcd" {
  length           = 16
  special          = false
}