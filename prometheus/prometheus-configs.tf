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
  terracd_jobs   = [
    {
      label                    = "time-in-files"
      plan_interval_threshold  = 60
      apply_interval_threshold = 600
      unit                     = "minute"
    }
  ]
}