resource "local_file" "file" {
  content         = var.content
  file_permission = "0660"
  filename        = pathexpand("~/Projects/terracd-test/${var.name}")
}