locals {
  params = jsondecode(file("${path.module}/../../../../shared/params.json"))
}

provider "minio" {
  minio_server     = "minio.ferlab.lan:9000"
  minio_ssl        = true 
  minio_user       = local.params.minio.root_username
  minio_password   = local.params.minio.root_password
  minio_cacert_file = "${path.module}/../../../../shared/minio_ca.crt"
}

resource "minio_s3_bucket" "phenovar_resources" {
  bucket        = "phenovar-resources"
  acl           = "private"
  force_destroy = false
}