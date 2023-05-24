module "nfs_ca" {
  source = "../ca"
  common_name = "nfs"
}

resource "local_file" "nfs_ca_cert" {
  content         = module.nfs_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/nfs-ca.crt"
}

resource "local_file" "nfs_ca_key" {
  content         = module.nfs_ca.key
  file_permission = "0600"
  filename        = "${path.module}/../shared/nfs-ca.key"
}

resource "tls_private_key" "nfs_tunnel_server_key" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "tls_cert_request" "nfs_tunnel_server_request" {
  private_key_pem = tls_private_key.nfs_tunnel_server_key.private_key_pem
  subject {
    common_name  = "nfs-server"
    organization = "Ferlab"
  }
  dns_names       = ["nfs.ferlab.lan"]
}

resource "tls_locally_signed_cert" "nfs_tunnel_server_certificate" {
  cert_request_pem   = tls_cert_request.nfs_tunnel_server_request.cert_request_pem
  ca_private_key_pem = module.nfs_ca.key
  ca_cert_pem        = module.nfs_ca.certificate

  validity_period_hours = 365 * 24
  early_renewal_hours = 14 * 24

  allowed_uses = [
    "server_auth",
  ]

  is_ca_certificate = false
}