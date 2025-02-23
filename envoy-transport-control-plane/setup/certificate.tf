module "envoy_ca" {
  source = "../../ca"
  common_name = "envoy"
}

resource "tls_private_key" "envoy" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "envoy" {
  private_key_pem = tls_private_key.envoy.private_key_pem
  dns_names = [
    "simple-service.ferlab.lan"
  ]
  ip_addresses = [
    "127.0.0.1"
  ]
  subject {
    common_name  = "envoy"
    organization = "Ferlab"
  }
}

resource "tls_locally_signed_cert" "envoy" {
  cert_request_pem   = tls_cert_request.envoy.cert_request_pem
  ca_private_key_pem = module.envoy_ca.key
  ca_cert_pem        = module.envoy_ca.certificate

  validity_period_hours = 87600
  early_renewal_hours   = 720

  allowed_uses = [
    "server_auth",
  ]
}

resource "local_file" "ca_cert" {
  content         = module.envoy_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../work-env/envoy_ca.crt"
}

resource "local_file" "envoy_cert" {
  content         = tls_locally_signed_cert.envoy.cert_pem
  file_permission = "0600"
  filename        = "${path.module}/../work-env/server.crt"
}

resource "local_file" "envoy_key" {
  content         = tls_private_key.envoy.private_key_pem
  file_permission = "0600"
  filename        = "${path.module}/../work-env/server.key"
}