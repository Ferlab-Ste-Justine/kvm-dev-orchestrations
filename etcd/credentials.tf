module "etcd_ca" {
  source = "../ca"
  common_name = "etcd"
}

resource "local_file" "etcd_ca_cert" {
  content         = module.etcd_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/etcd-ca.pem"
}

resource "local_file" "etcd_ca_key" {
  content         = module.etcd_ca.key
  file_permission = "0600"
  filename        = "${path.module}/../shared/etcd-ca.key"
}

resource "local_file" "etcd_ca_key_algorithm" {
  content         = module.etcd_ca.key_algorithm
  file_permission = "0600"
  filename        = "${path.module}/../shared/etcd-ca_key_algorithm"
}

resource "tls_private_key" "etcd" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "tls_cert_request" "etcd" {
  private_key_pem = tls_private_key.etcd.private_key_pem
  ip_addresses    = concat([
      local.params.etcd.addresses.0.ip,
      local.params.etcd.addresses.1.ip,
      local.params.etcd.addresses.2.ip
    ], ["127.0.0.1"])
  subject {
    common_name  = "etcd"
    organization = "Ferlab"
  }
}

resource "tls_locally_signed_cert" "etcd" {
  cert_request_pem   = tls_cert_request.etcd.cert_request_pem
  ca_private_key_pem = module.etcd_ca.key
  ca_cert_pem        = module.etcd_ca.certificate

  validity_period_hours = 100*365*24
  early_renewal_hours = 365*24

  allowed_uses = [
    "client_auth",
    "server_auth",
  ]

  is_ca_certificate = false
}

resource "random_password" "etcd_root_password" {
  length           = 16
  special          = false
}

resource "local_file" "etcd_root_password" {
  content         = random_password.etcd_root_password.result
  file_permission = "0600"
  filename        = "${path.module}/../shared/etcd-root_password"
}