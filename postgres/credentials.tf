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

resource "tls_private_key" "patroni_client_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

module "postgres_certificates" {
  source = "./terraform-tls-patroni-certificates"
  ca = {
    certificate = module.postgres_ca.certificate
    key = module.postgres_ca.key
  }
  client_key = tls_private_key.patroni_client_key.private_key_pem
  server_key = tls_private_key.postgres_server_key.private_key_pem
  cluster_ips = concat([for addr in netaddr_address_ipv4.postgres: addr.address], [netaddr_address_ipv4.postgres_lb.0.address])
  cluster_domains = ["postgres.ferlab.lan", "load-balancer.postgres.ferlab.lan", "server.postgres.ferlab.lan"]
  organization = "ferlab"
}

resource "local_file" "patroni_client_cert" {
  content         = module.postgres_certificates.client_certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/patroni_client.crt"
}

resource "local_file" "patroni_client_key" {
  content         = tls_private_key.patroni_client_key.private_key_pem
  file_permission = "0600"
  filename        = "${path.module}/../shared/patroni_client.key"
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