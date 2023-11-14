resource "local_file" "node_exporter_confs" {
  for_each        = { for node_exporter_job in var.node_exporter_jobs : node_exporter_job.label => node_exporter_job }
  content         = templatefile(
    "${path.module}/templates/node-exporter.yml.tpl",
    {
      job = each.value
    }
  )
  file_permission = "0600"
  filename        = "${var.fs_path}/rules/${each.value.label}-node-exporter.yml"
}

resource "local_file" "prometheus_conf" {
  content         = templatefile(
    "${var.fs_path}/prometheus.yml.tpl",
    {
      alertmanager_enabled = var.alertmanager_enabled
      node_exporter_rule_paths = [for node_exporter_job in var.node_exporter_jobs: "rules/${node_exporter_job.label}-node-exporter.yml"]
    }
  )
  file_permission = "0600"
  filename        = "${var.fs_path}/prometheus.yml"
}

resource "etcd_synchronized_directory" "prometheus_confs" {
    directory = var.fs_path
    key_prefix = var.etcd_key_prefix
    source = "directory"
    recurrence = "onchange"

    depends_on = [
      local_file.prometheus_conf,
      local_file.node_exporter_confs
    ]
}