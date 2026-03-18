provider "minio" {
  minio_server     = "minio.ferlab.lan:9000"
  minio_ssl        = true 
  minio_user       = "minio"
  minio_password   = "testtest"
  minio_cacert_file = "${path.module}/../shared/minio_ca.crt"
}
