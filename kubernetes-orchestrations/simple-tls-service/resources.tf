resource "kubernetes_secret" "simple_service_ingress_tls" {
  metadata {
    name      = "simple-service-ingress-tls"
    namespace = "default"
  }

  data = {
    "tls.crt" = tls_locally_signed_cert.simple_service.cert_pem
    "tls.key" = tls_private_key.simple_service.private_key_pem
  }

  type = "kubernetes.io/tls"
}

resource "kubectl_manifest" "service" {
    yaml_body = file("${path.module}/service.yml")
}

resource "kubectl_manifest" "deployment" {
    yaml_body = file("${path.module}/deployment.yml")
}

resource "kubectl_manifest" "ingress" {
    yaml_body = file("${path.module}/ingress.yml")
}

