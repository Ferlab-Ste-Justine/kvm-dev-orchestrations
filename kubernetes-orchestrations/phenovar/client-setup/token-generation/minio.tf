locals {
  params = jsondecode(file("${path.module}/../../../../shared/params.json"))
}

resource "kubernetes_secret" "phenovar_minio_credentials" {
  metadata {
    name = "phenovar-minio-credentials"
    namespace = "phenovar"
  }

  data = {
    "S3_ACCESS_KEY" = local.params.minio.root_username
    "S3_SECRET_KEY" = local.params.minio.root_password
  }
}