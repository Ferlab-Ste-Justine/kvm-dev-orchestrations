resource "etcd_synchronized_directory" "config" {
  directory = "${path.module}/config"
  key_prefix = "/bootstrap/configurations/"
  source = "directory"
  recurrence = "onchange"
}

resource "etcd_synchronized_directory" "fluentbit_config" {
  directory = "${path.module}/fluent-bit-config"
  key_prefix = "/bootstrap/fluent-bit/"
  source = "directory"
  recurrence = "onchange"
}