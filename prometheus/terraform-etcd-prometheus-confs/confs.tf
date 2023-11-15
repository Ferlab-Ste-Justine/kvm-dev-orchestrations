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

resource "local_file" "terracd_confs" {
  for_each        = { for terracd_job in var.terracd_jobs : terracd_job.label => terracd_job }
  content         = templatefile(
    "${path.module}/templates/terracd.yml.tpl",
    {
      job = each.value
    }
  )
  file_permission = "0600"
  filename        = "${var.fs_path}/rules/${each.value.label}-terracd.yml"
}

locals {
  parsed_config = yamldecode(var.config)
  rule_files = concat(
    contains(keys(local.parsed_config), "rule_files") ? local.parsed_config.rule_files : [],
    [for node_exporter_job in var.node_exporter_jobs: "rules/${node_exporter_job.label}-node-exporter.yml"],
    [for terracd_job in var.terracd_jobs: "rules/${terracd_job.label}-terracd.yml"]
  )
}

resource "local_file" "prometheus_conf" {
  content         = yamlencode(merge(local.parsed_config, {rule_files=local.rule_files}))
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
      local_file.node_exporter_confs,
      local_file.terracd_confs
    ]
}