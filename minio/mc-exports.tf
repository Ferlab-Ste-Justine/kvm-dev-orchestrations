resource "local_file" "mc_config" {
  content         = templatefile(
    "${path.module}/templates/config.json.tpl",
    {
      access_key = local.params.minio.root_username
      secret_key = local.params.minio.root_password
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/../shared/.mc/config.json"
}

resource "local_file" "mc_ca" {
  content         = module.minio_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/.mc/CAs/ca.crt"
}