resource "etcd_synchronized_directory" "config" {
  directory = "${path.module}/config"
  key_prefix = "/bootstrap/configurations/"
  source = "directory"
  recurrence = "onchange"
}