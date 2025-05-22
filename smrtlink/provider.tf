provider "minio" {
  minio_server       = "minio.ferlab.lan:9000"
  minio_ssl          = true 
  minio_access_key   = local.params.minio.root_username
  minio_secret_key   = local.params.minio.root_password
}
