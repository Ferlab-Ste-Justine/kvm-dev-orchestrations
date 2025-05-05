module "ca" {
  source = "./ca"
  common_name = "terracd"
}

resource "tls_private_key" "server" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem

  subject {
    common_name  = "localhost"
    organization = "terracd"
  }

  ip_addresses = ["127.0.0.1", local.host_params.ip]
}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem   = tls_cert_request.server.cert_request_pem
  ca_private_key_pem = module.ca.key
  ca_cert_pem        = module.ca.certificate

  validity_period_hours = 100*365*24
  early_renewal_hours = 365*24

  allowed_uses = [
    "server_auth",
  ]

  is_ca_certificate = false
}

resource "tls_private_key" "client" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "client" {
  private_key_pem = tls_private_key.client.private_key_pem

  subject {
    common_name  = "user"
    organization = "ferlab"
  }
}

resource "tls_locally_signed_cert" "client" {
  cert_request_pem   = tls_cert_request.client.cert_request_pem
  ca_private_key_pem = module.ca.key
  ca_cert_pem        = module.ca.certificate

  validity_period_hours = 100*365*24
  early_renewal_hours = 365*24

  allowed_uses = [
    "client_auth",
  ]

  is_ca_certificate = false
}

resource "local_file" "ca_cert" {
  content         = module.ca.certificate
  file_permission = "0660"
  filename        = pathexpand("${path.module}/../certs/local_ca.crt")
}

resource "local_file" "server_cert" {
  content         = tls_locally_signed_cert.server.cert_pem
  file_permission = "0660"
  filename        = pathexpand("${path.module}/../certs/local_server.crt")
}

resource "local_file" "server_key" {
  content         = tls_private_key.server.private_key_pem
  file_permission = "0660"
  filename        = pathexpand("${path.module}/../certs/local_server.key")
}

resource "local_file" "client_cert" {
  content         = tls_locally_signed_cert.client.cert_pem
  file_permission = "0660"
  filename        = pathexpand("${path.module}/../certs/local_client.crt")
}

resource "local_file" "client_key" {
  content         = tls_private_key.client.private_key_pem
  file_permission = "0660"
  filename        = pathexpand("${path.module}/../certs/local_client.key")
}

resource "local_file" "config" {
  content         = file("${path.module}/config.yml")
  file_permission = "0660"
  filename        = pathexpand("${path.module}/../confs/config.yml")
}