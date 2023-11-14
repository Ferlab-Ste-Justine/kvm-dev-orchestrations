/*resource "local_file" "prometheus_config" {
  content         = templatefile(
    "${path.module}/prometheus-configs/prometheus.yml.tpl",
    {
        alertmanager_enabled = fileexists("${path.module}/../shared/alertmanager_ca.crt") ? true : false
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/prometheus-configs/prometheus.yml"
}

resource "local_file" "prometheus_automation_server_node_exported_config" {
  content         = templatefile(
    "${path.module}/prometheus-templates/node-exporter.yml.tpl",
    {
        label                  = "automation-server"
        expected_count         = 1
        memory_usage_threshold = 90
        cpu_usage_threshold    = 90
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/prometheus-configs/rules/automation-server.yml"
}

resource "etcd_synchronized_directory" "prometheus_confs" {
    directory = "${path.module}/prometheus-configs"
    key_prefix = "/ferlab/prometheus/"
    source = "directory"
    recurrence = "onchange"

    depends_on = [
      local_file.prometheus_config,
      local_file.prometheus_automation_server_node_exported_config
    ]
}*/

module "prometheus_confs" {
  source               = "./terraform-etcd-prometheus-confs"
  etcd_key_prefix      = "/ferlab/prometheus/"
  fs_path              = "${path.module}/prometheus-configs"
  alertmanager_enabled = fileexists("${path.module}/../shared/alertmanager_ca.crt") ? true : false
  node_exporter_jobs   = [
    {
      label                      = "etcd"
      expected_count             = 3
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
    },
    {
      label                      = "coredns"
      expected_count             = 1
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
    },
    {
      label                      = "prometheus"
      expected_count             = 1
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
    },
    {
      label                      = "alertmanager"
      expected_count             = 1
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
    },
    {
      label                      = "automation-server"
      expected_count             = 1
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
    },
    {
      label                      = "dhcp"
      expected_count             = 1
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
    }
  ]
}