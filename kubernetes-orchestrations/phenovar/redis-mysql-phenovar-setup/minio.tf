resource "kubernetes_secret" "minio_ca" {
  metadata {
    name = "minio-ca"
    namespace = "phenovar"
  }

  data = {
    "ca.crt" = file("${path.module}/../../../shared/minio_ca.crt")
  }

  depends_on = [kubernetes_namespace.phenovar]
}