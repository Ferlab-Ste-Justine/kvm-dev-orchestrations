module "pushgateway_ca" {
  source = "../ca"
  common_name = "automation-server-push-gateway"
}

resource "tls_private_key" "pushgateway" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "tls_cert_request" "pushgateway" {
  private_key_pem = tls_private_key.pushgateway.private_key_pem
  subject {
    common_name  = "automation-server-push-gateway"
    organization = "Ferlab"
  }
  ip_addresses   = [
    "127.0.0.10",
    local.params.automation_server.address.ip
  ]
  dns_names = [
    "automation.ferlab.lan"
  ]
}

resource "tls_locally_signed_cert" "pushgateway" {
  cert_request_pem   = tls_cert_request.pushgateway.cert_request_pem
  ca_private_key_pem = module.pushgateway_ca.key
  ca_cert_pem        = module.pushgateway_ca.certificate

  validity_period_hours = 365 * 24
  early_renewal_hours = 14 * 24

  allowed_uses = [
    "client_auth",
    "server_auth",
  ]

  is_ca_certificate = false
}

resource "local_file" "pushgateway_ca_cert" {
  content         = module.pushgateway_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/automation_server_pushgateway_ca.crt"
}

resource "local_file" "pushgateway_cert" {
  content         = tls_locally_signed_cert.pushgateway.cert_pem
  file_permission = "0600"
  filename        = "${path.module}/../shared/automation_server_pushgateway.crt"
}

resource "local_file" "pushgateway_key" {
  content         = tls_private_key.pushgateway.private_key_pem
  file_permission = "0600"
  filename        = "${path.module}/../shared/automation_server_pushgateway.key"
}