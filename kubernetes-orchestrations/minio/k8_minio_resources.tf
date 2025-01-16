resource "kubernetes_endpoints" "minio_api" {
  metadata {
    name      = "minio-api"
  }

  subset {
    dynamic "address" {
      for_each = data.netaddr_address_ipv4.minio
      content {
        ip = address.value.address
      }
    }

    port {
      port     = 9000
      protocol = "TCP"
    }
  }
}

resource "kubernetes_service" "minio_api" {
  metadata {
    name      = "minio-api"
  }

  spec {

    port {
      port        = 9000
      target_port = 9000
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_endpoints" "minio_console" {
  metadata {
    name      = "minio-console"
  }

  subset {
    dynamic "address" {
      for_each = data.netaddr_address_ipv4.minio
      content {
        ip = address.value.address
      }
    }

    port {
      port     = 9001
      protocol = "TCP"
    }
  }
}

resource "kubernetes_service" "minio_console" {
  metadata {
    name      = "minio-console"
  }

  spec {
    port {
      port        = 9001
      target_port = 9001
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_secret" "minio_ingress_tls" {
  metadata {
    name      = "minio-ingress-tls"
    namespace = "default"
  }

  data = {
    "tls.crt" = tls_locally_signed_cert.minio.cert_pem
    "tls.key" = tls_private_key.minio.private_key_pem
  }

  type = "kubernetes.io/tls"
}
