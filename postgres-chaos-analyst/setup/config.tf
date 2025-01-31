resource "local_file" "config" {
  content         = file("${path.module}/config.yml")
  file_permission = "0600"
  filename        = "${path.module}/../postgres-chaos-analyst/config.yml"
}