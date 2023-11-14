resource "local_file" "prometheus_config" {
  content         = templatefile(
    "${path.module}/prometheus-configs/prometheus.yml.tpl",
    {
        alertmanager_enabled = fileexists("${path.module}/../shared/alertmanager_ca.crt") ? true : false
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/prometheus-configs/prometheus.yml"
}

resource "etcd_synchronized_directory" "prometheus_confs" {
    directory = "${path.module}/prometheus-configs"
    key_prefix = "/ferlab/prometheus/"
    source = "directory"
    recurrence = "onchange"

    depends_on = [local_file.prometheus_config]
}