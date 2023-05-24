resource "etcd_synchronized_directory" "prometheus_confs" {
    directory = "${path.module}/prometheus-configs"
    key_prefix = "/ferlab/prometheus/"
    source = "directory"
    recurrence = "onchange"
}