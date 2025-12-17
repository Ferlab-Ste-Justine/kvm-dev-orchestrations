module "phenovar_ingress_ca" {
  source = "../../../ca-ecdsa-p256"
  common_name = "phenovar"
}

resource "tls_private_key" "phenovar" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "phenovar" {
  private_key_pem = tls_private_key.phenovar.private_key_pem
  dns_names = [
    "phenovar.k8.ferlab.lan",
    "phenovar-flower.k8.ferlab.lan"
  ]
  subject {
    common_name  = "phenovar.k8.ferlab.lan"
    organization = "Ferlab"
  }
}

resource "tls_locally_signed_cert" "phenovar" {
  cert_request_pem   = tls_cert_request.phenovar.cert_request_pem
  ca_private_key_pem = module.phenovar_ingress_ca.key
  ca_cert_pem        = module.phenovar_ingress_ca.certificate

  validity_period_hours = 87600
  early_renewal_hours   = 720

  allowed_uses = [
    "server_auth",
  ]
}

resource "kubernetes_secret" "phenovar_ingress_tls" {
  metadata {
    name      = "phenovar-ingress-tls"
    namespace = "phenovar"
  }

  data = {
    "tls.crt" = "${tls_locally_signed_cert.phenovar.cert_pem}\n${module.phenovar_ingress_ca.certificate}"
    "tls.key" = tls_private_key.phenovar.private_key_pem
  }

  type = "kubernetes.io/tls"

  depends_on = [kubernetes_namespace.phenovar]
}

resource "local_file" "ca_cert" {
  content         = module.phenovar_ingress_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../../../shared/phenovar_ingress_ca.crt"
}