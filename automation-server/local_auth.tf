module "automation_server_ca" {
  source = "../ca"
  common_name = "automation-server"
}

resource "tls_private_key" "automation_server" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "tls_cert_request" "automation_server" {
  private_key_pem = tls_private_key.automation_server.private_key_pem
  subject {
    common_name  = "automation-server"
    organization = "Ferlab"
  }
  ip_addresses   = ["127.0.0.10"]
}

resource "tls_locally_signed_cert" "automation_server" {
  cert_request_pem   = tls_cert_request.automation_server.cert_request_pem
  ca_private_key_pem = module.automation_server_ca.key
  ca_cert_pem        = module.automation_server_ca.certificate

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