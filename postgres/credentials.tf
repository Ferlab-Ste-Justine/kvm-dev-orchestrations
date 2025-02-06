module "postgres_ca" {
  source = "../ca"
  common_name = "postgres"
}

resource "local_file" "postgres_ca_cert" {
  content         = module.postgres_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/postgres_ca.crt"
}

resource "local_file" "postgres_ca_key" {
  content         = module.postgres_ca.key
  file_permission = "0600"
  filename        = "${path.module}/../shared/postgres_ca.key"
}

resource "tls_private_key" "postgres_server_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "postgres_request" {
  private_key_pem = tls_private_key.postgres_server_key.private_key_pem

  subject {
    common_name  = "postgres"
    organization = "ferlab"
  }

  dns_names = concat(["postgres.ferlab.lan", "load-balancer.postgres.ferlab.lan", "server.postgres.ferlab.lan", netaddr_address_ipv4.postgres_lb.0.address], [for addr in netaddr_address_ipv4.postgres: addr.address], ["127.0.0.1", "localhost"])
  ip_addresses = concat([for addr in netaddr_address_ipv4.postgres: addr.address], [netaddr_address_ipv4.postgres_lb.0.address, "127.0.0.1"])
}

resource "tls_locally_signed_cert" "postgres_server_certificate" {
  cert_request_pem   = tls_cert_request.postgres_request.cert_request_pem
  ca_private_key_pem = module.postgres_ca.key
  ca_cert_pem        = module.postgres_ca.certificate

  validity_period_hours = 2400
  early_renewal_hours = 10

  allowed_uses = [
    "server_auth",
  ]

  is_ca_certificate = false
}

resource "random_password" "postgres_root_password" {
  length           = 16
  special          = false
}

resource "local_file" "postgres_root_password" {
  content         = random_password.postgres_root_password.result
  file_permission = "0600"
  filename        = "${path.module}/../shared/postgres_root_password"
}

resource "local_file" "postgres_root_auth" {
  content         = "username: postgres\npassword: \"${random_password.postgres_root_password.result}\""
  file_permission = "0600"
  filename        = "${path.module}/../shared/postgres_root_auth.yml"
}

//Patroni client cert
resource "tls_private_key" "patroni_client_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "patroni_client_request" {
  private_key_pem = tls_private_key.patroni_client_key.private_key_pem

  subject {
    common_name  = "patroni-client"
    organization = "ferlab"
  }
}

resource "tls_locally_signed_cert" "patroni_client_certificate" {
  cert_request_pem   = tls_cert_request.patroni_client_request.cert_request_pem
  ca_private_key_pem = module.postgres_ca.key
  ca_cert_pem        = module.postgres_ca.certificate

  validity_period_hours = 2400
  early_renewal_hours = 10

  allowed_uses = [
    "client_auth",
  ]

  is_ca_certificate = false
}

resource "local_file" "patroni_client_cert" {
  content         = tls_locally_signed_cert.patroni_client_certificate.cert_pem
  file_permission = "0600"
  filename        = "${path.module}/../shared/patroni_client.crt"
}

resource "local_file" "patroni_client_key" {
  content         = tls_private_key.patroni_client_key.private_key_pem
  file_permission = "0600"
  filename        = "${path.module}/../shared/patroni_client.key"
}