module "simple_service_ca" {
  source = "../../ca-ecdsa-p256"
  common_name = "simple-service"
}

resource "tls_private_key" "simple_service" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "simple_service" {
  private_key_pem = tls_private_key.simple_service.private_key_pem
  dns_names = [
    "simple-service.k8.ferlab.lan",
  ]
  ip_addresses = [
    data.netaddr_address_ipv4.k8_lb.address
  ]
  subject {
    common_name  = "simple-service.k8.ferlab.lan"
    organization = "Ferlab"
  }
}

resource "tls_locally_signed_cert" "simple_service" {
  cert_request_pem   = tls_cert_request.simple_service.cert_request_pem
  ca_private_key_pem = module.simple_service_ca.key
  ca_cert_pem        = module.simple_service_ca.certificate

  validity_period_hours = 87600
  early_renewal_hours   = 720

  allowed_uses = [
    "server_auth",
  ]
}

resource "local_file" "ca_cert" {
  content         = module.simple_service_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../../shared/simple_service_ca.crt"
}

resource "local_file" "server_cert" {
  content         = tls_locally_signed_cert.simple_service.cert_pem
  file_permission = "0600"
  filename        = "${path.module}/../../shared/simple_service.crt"
}


resource "tls_private_key" "simple_service_client" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "simple_service_client" {
  private_key_pem = tls_private_key.simple_service_client.private_key_pem
  subject {
    common_name  = "simple-service.k8.ferlab.lan"
    organization = "Ferlab"
  }
}

resource "tls_locally_signed_cert" "simple_service_client" {
  cert_request_pem   = tls_cert_request.simple_service_client.cert_request_pem
  ca_private_key_pem = module.simple_service_ca.key
  ca_cert_pem        = module.simple_service_ca.certificate

  validity_period_hours = 87600
  early_renewal_hours   = 720

  allowed_uses = [
    "client_auth",
  ]
}

resource "local_file" "client_cert" {
  content         = tls_locally_signed_cert.simple_service_client.cert_pem
  file_permission = "0600"
  filename        = "${path.module}/../../shared/simple_service_client.crt"
}

resource "local_file" "client_key" {
  content         = tls_private_key.simple_service_client.private_key_pem
  file_permission = "0600"
  filename        = "${path.module}/../../shared/simple_service_client.key"
}