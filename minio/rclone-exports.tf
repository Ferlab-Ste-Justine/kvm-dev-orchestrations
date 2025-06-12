resource "local_file" "rclone_config" {
  content         = templatefile(
    "${path.module}/templates/rclone.conf.tpl",
    {
      root_username = local.params.minio.root_username
      root_password = local.params.minio.root_password
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/../shared/minio_rclone.conf"
}