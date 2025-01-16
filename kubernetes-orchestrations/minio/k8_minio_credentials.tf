module "minio_ca" {
  source = "../../ca"
  common_name = "minio"
}

resource "tls_private_key" "minio" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "minio" {
  private_key_pem = tls_private_key.minio.private_key_pem
  dns_names = [
    "minio-api.k8.ferlab.lan",
    "minio-console.k8.ferlab.lan",
    "*.minio.k8.ferlab.lan"
  ]
  ip_addresses = [
    data.netaddr_address_ipv4.k8_lb.address
  ]
  subject {
    common_name  = "minio.k8.ferlab.lan"
    organization = "Ferlab"
  }
}

resource "tls_locally_signed_cert" "minio" {
  cert_request_pem   = tls_cert_request.minio.cert_request_pem
  ca_private_key_pem = module.minio_ca.key
  ca_cert_pem        = module.minio_ca.certificate

  validity_period_hours = 87600
  early_renewal_hours   = 720

  allowed_uses = [
    "client_auth",
    "server_auth",
  ]
}

# Output the files locally
resource "local_file" "minio_tls_cert" {
  content  = tls_locally_signed_cert.minio.cert_pem
  filename = "${path.module}/../../shared/minio_tls.crt"
}

resource "local_file" "minio_tls_key" {
  content  = tls_private_key.minio.private_key_pem
  filename = "${path.module}/../../shared/minio_tls.key"
}

resource "local_file" "minio_ca_cert" {
  content  = module.minio_ca.certificate
  filename = "${path.module}/../../shared/minio_ca.crt"
}