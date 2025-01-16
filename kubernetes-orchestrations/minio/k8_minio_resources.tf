provider "kubernetes" {
  config_path  = "../../shared/kubeconfig"   # Path to your kubeconfig file
  config_context = "kubernetes-admin-ferlab@ferlab" # Set your kubeconfig context
}

resource "kubernetes_endpoints" "minio_api" {
  metadata {
    name      = "minio-api"
  }

  subset {
    address {
      ip = "192.168.55.24"
    }
    address {
      ip = "192.168.55.26"
    }
    address {
      ip = "192.168.55.27"
    }
    address {
      ip = "192.168.55.25"
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
    address {
      ip = "192.168.55.24"
    }
    address {
      ip = "192.168.55.26"
    }
    address {
      ip = "192.168.55.27"
    }
    address {
      ip = "192.168.55.25"
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
    "tls.crt" = filebase64("../../shared/minio_tls.crt")
    "tls.key" = filebase64("../../shared/minio_tls.key")
  }

  type = "kubernetes.io/tls"
}
