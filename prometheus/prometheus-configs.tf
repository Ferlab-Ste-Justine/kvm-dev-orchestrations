resource "null_resource" "prometheus_yml_generated" {
  provisioner "local-exec" {
    command = "echo '${templatefile("${path.module}/prometheus-configs/prometheus.yml.tpl", local.params.prometheus)}' > ${path.module}/prometheus-configs/prometheus.yml"
  }
}

resource "etcd_synchronized_directory" "prometheus_confs" {
    directory = "${path.module}/prometheus-configs"
    key_prefix = "/ferlab/prometheus/"
    source = "directory"
    recurrence = "onchange"
}