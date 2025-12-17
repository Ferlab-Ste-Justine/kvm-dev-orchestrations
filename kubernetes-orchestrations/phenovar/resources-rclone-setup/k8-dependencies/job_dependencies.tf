resource "kubernetes_namespace" "phenovar_ops" {
  metadata {
    name = "phenovar-ops"
  }
}

resource "kubernetes_secret" "rclone_conf" {
  metadata {
    name = "phenovar-resources-rclone-conf"
    namespace = "phenovar-ops"
  }

  data = {
    "rclone.conf" = file("${path.module}/../../../../shared/minio_rclone.conf")
  }

  depends_on = [kubernetes_namespace.phenovar_ops]
}

resource "kubernetes_secret" "minio_ca" {
  metadata {
    name = "minio-ca"
    namespace = "phenovar-ops"
  }

  data = {
    "ca.crt" = file("${path.module}/../../../../shared/minio_ca.crt")
  }

  depends_on = [kubernetes_namespace.phenovar_ops]
}