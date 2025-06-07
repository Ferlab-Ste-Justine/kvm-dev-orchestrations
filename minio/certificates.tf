module "minio_ca" {
  source = "../ca"
  common_name = "minio"
}

resource "tls_private_key" "minio" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "tls_cert_request" "minio" {
  private_key_pem = tls_private_key.minio.private_key_pem
  ip_addresses    = concat([
      netaddr_address_ipv4.minio.0.address,
      netaddr_address_ipv4.minio.1.address,
      netaddr_address_ipv4.minio.2.address,
      netaddr_address_ipv4.minio.3.address
    ], ["127.0.0.1"])
  dns_names = [
    "minio.ferlab.lan",
    "*.minio.ferlab.lan",
    "minio",
    "minio-api",
    "minio-console"
  ]
  subject {
    common_name  = "minio"
    organization = "Ferlab"
  }
}

resource "tls_locally_signed_cert" "minio" {
  cert_request_pem   = tls_cert_request.minio.cert_request_pem
  ca_private_key_pem = module.minio_ca.key
  ca_cert_pem        = module.minio_ca.certificate

  validity_period_hours = 100*365*24
  early_renewal_hours = 365*24

  allowed_uses = [
    "client_auth",
    "server_auth",
  ]

  is_ca_certificate = false
}

resource "local_file" "minio_ca_cert" {
  content         = module.minio_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/minio_ca.crt"
}

resource "local_file" "minio_ca_key" {
  content         = module.minio_ca.key
  file_permission = "0600"
  filename        = "${path.module}/../shared/minio_ca.key"
}

module "minio_ingress_ca" {
  source = "../ca"
  common_name = "minio"
}

resource "local_file" "minio_ingress_ca_cert" {
  content         = module.minio_ingress_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/minio_ingress_ca.crt"
}

resource "local_file" "minio_ingress_ca_key" {
  content         = module.minio_ingress_ca.key
  file_permission = "0600"
  filename        = "${path.module}/../shared/minio_ingress_ca.key"
}

#First tenant
resource "tls_cert_request" "ferlab_tenant_client_sse" {
  private_key_pem = tls_private_key.minio.private_key_pem
  subject {
    common_name  = "ferlab"
    organization = "Ferlab"
  }
}

resource "tls_locally_signed_cert" "ferlab_tenant_client_sse" {
  cert_request_pem   = tls_cert_request.ferlab_tenant_client_sse.cert_request_pem
  ca_private_key_pem = module.minio_ca.key
  ca_cert_pem        = module.minio_ca.certificate

  validity_period_hours = 100*365*24
  early_renewal_hours = 365*24

  allowed_uses = [
    "client_auth",
  ]

  is_ca_certificate = false
}

#Second tenant
resource "tls_cert_request" "ferlab2_tenant_client_sse" {
  private_key_pem = tls_private_key.minio.private_key_pem
  subject {
    common_name  = "ferlab2"
    organization = "Ferlab"
  }
}

resource "tls_locally_signed_cert" "ferlab2_tenant_client_sse" {
  cert_request_pem   = tls_cert_request.ferlab2_tenant_client_sse.cert_request_pem
  ca_private_key_pem = module.minio_ca.key
  ca_cert_pem        = module.minio_ca.certificate

  validity_period_hours = 100*365*24
  early_renewal_hours = 365*24

  allowed_uses = [
    "client_auth",
  ]

  is_ca_certificate = false
}