module "pushgateway_ca" {
  source = "../../../ca-ecdsa-p256"
  common_name = "prometheus-pushgateway"
}

resource "tls_private_key" "pushgateway_server" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "pushgateway_server" {
  private_key_pem = tls_private_key.pushgateway_server.private_key_pem
  dns_names = [
    "prometheus-pushgateway",
    "prometheus-pushgateway.prometheus-pushgateway",
    "prometheus-pushgateway.k8.ferlab.lan"
  ]
  subject {
    common_name  = "prometheus-pushgateway.k8.ferlab.lan"
    organization = "Ferlab"
  }
}

resource "tls_locally_signed_cert" "pushgateway_server" {
  cert_request_pem   = tls_cert_request.pushgateway_server.cert_request_pem
  ca_private_key_pem = module.pushgateway_ca.key
  ca_cert_pem        = module.pushgateway_ca.certificate

  validity_period_hours = 87600
  early_renewal_hours   = 720

  allowed_uses = [
    "server_auth",
  ]
}

resource "kubernetes_secret" "pushgateway_server_certs" {
  metadata {
    name      = "pushgateway-server-certs"
    namespace = "prometheus-pushgateway"
  }

  data = {
    "server.crt" = "${tls_locally_signed_cert.pushgateway_server.cert_pem}\n${module.pushgateway_ca.certificate}"
    "server.key" = tls_private_key.pushgateway_server.private_key_pem
    "ca.crt" = module.pushgateway_ca.certificate
  }

  depends_on = [kubernetes_namespace.pushgateway]
}

resource "tls_private_key" "pushgateway_client" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "pushgateway_client" {
  private_key_pem = tls_private_key.pushgateway_client.private_key_pem
  
  subject {
    common_name  = "prometheus-pushgateway-client"
    organization = "Ferlab"
  }
}

resource "tls_locally_signed_cert" "pushgateway_client" {
  cert_request_pem   = tls_cert_request.pushgateway_client.cert_request_pem
  ca_private_key_pem = module.pushgateway_ca.key
  ca_cert_pem        = module.pushgateway_ca.certificate

  validity_period_hours = 87600
  early_renewal_hours   = 720

  allowed_uses = [
    "client_auth",
  ]
}

resource "local_file" "ca_cert" {
  content         = module.pushgateway_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../../../shared/pushgateway_ca.crt"
}

resource "local_file" "client_cert" {
  content         = tls_locally_signed_cert.pushgateway_client.cert_pem
  file_permission = "0600"
  filename        = "${path.module}/../../../shared/pushgateway_client.crt"
}

resource "local_file" "client_key" {
  content         = tls_private_key.pushgateway_client.private_key_pem
  file_permission = "0600"
  filename        = "${path.module}/../../../shared/pushgateway_client.key"
}