module "simple_service_ca" {
  source = "../../ca"
  common_name = "simple-service"
}

resource "tls_private_key" "simple_service" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "simple_service" {
  private_key_pem = tls_private_key.simple_service.private_key_pem
  dns_names = [
    "simple-service.k8.ferlab.lan"
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