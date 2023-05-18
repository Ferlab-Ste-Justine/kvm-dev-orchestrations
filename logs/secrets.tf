resource "random_password" "logs_shared_key" {
  length           = 16
  special          = false
}

resource "local_file" "logs_shared_key" {
  content         = random_password.logs_shared_key.result
  file_permission = "0600"
  filename        = "${path.module}/../shared/logs_shared_key"
}

locals {
  host_params = jsondecode(file("${path.module}/../shared/host_params.json"))
}

module "fluentd_server_ca" {
  source = "../ca"
  common_name = "fluentd"
}

resource "local_file" "ca_cert" {
  content         = module.fluentd_server_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/logs_ca.crt"
}

resource "local_file" "server_ca_cert" {
  content         = module.fluentd_server_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/certs/ca.crt"
}

resource "tls_private_key" "fluentd_server" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "tls_cert_request" "fluentd_server" {
  private_key_pem = tls_private_key.fluentd_server.private_key_pem
  subject {
    common_name  = "fluentd"
    organization = "Ferlab"
  }
  ip_addresses   = [local.host_params.ip]
}

resource "tls_locally_signed_cert" "fluentd_server" {
  cert_request_pem   = tls_cert_request.fluentd_server.cert_request_pem
  ca_private_key_pem = module.fluentd_server_ca.key
  ca_cert_pem        = module.fluentd_server_ca.certificate

  validity_period_hours = 365 * 24
  early_renewal_hours = 14 * 24

  allowed_uses = [
    "server_auth",
  ]

  is_ca_certificate = false
}

resource "local_file" "server_cert" {
  content         = tls_locally_signed_cert.fluentd_server.cert_pem
  file_permission = "0600"
  filename        = "${path.module}/certs/server.crt"
}

resource "local_file" "server_key" {
  content         = tls_private_key.fluentd_server.private_key_pem
  file_permission = "0600"
  filename        = "${path.module}/certs/server.key"
}