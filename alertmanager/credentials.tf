module "alertmanager_ca" {
  source = "../ca"
  common_name = "alertmanager"
}

resource "tls_private_key" "alertmanager" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "tls_cert_request" "alertmanager" {
  private_key_pem = tls_private_key.alertmanager.private_key_pem
  ip_addresses    = concat(
    [for alertmanager in netaddr_address_ipv4.alertmanager: alertmanager.address],
    ["127.0.0.1"]
  )
  dns_names = concat(
    [for idx, alertmanager in netaddr_address_ipv4.alertmanager: "server-${idx + 1}.alertmanager.ferlab.lan"],
    ["alertmanager.ferlab.lan"]
  )
  subject {
    common_name  = "alertmanager"
    organization = "Ferlab"
  }
}

resource "tls_locally_signed_cert" "alertmanager" {
  cert_request_pem   = tls_cert_request.alertmanager.cert_request_pem
  ca_private_key_pem = module.alertmanager_ca.key
  ca_cert_pem        = module.alertmanager_ca.certificate

  validity_period_hours = 100*365*24
  early_renewal_hours = 365*24

  allowed_uses = [
    "client_auth",
    "server_auth",
  ]

  is_ca_certificate = false
}

resource "random_password" "alertmanager_password" {
  length           = 16
  special          = false
}

resource "local_file" "alertmanager_password" {
  content         = random_password.alertmanager_password.result
  file_permission = "0600"
  filename        = "${path.module}/../shared/alertmanager_password"
}

resource "local_file" "alertmanager_ca_cert" {
  content         = module.alertmanager_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/alertmanager_ca.crt"
}

resource "local_file" "alertmanager_client_cert" {
  content         = tls_locally_signed_cert.alertmanager.cert_pem
  file_permission = "0600"
  filename        = "${path.module}/../shared/alertmanager_client.crt"
}

resource "local_file" "alertmanager_client_key" {
  content         = tls_private_key.alertmanager.private_key_pem
  file_permission = "0600"
  filename        = "${path.module}/../shared/alertmanager_client.key"
}