module "prometheus_confs" {
  source               = "./terraform-etcd-prometheus-configuration"
  etcd_key_prefix      = "/ferlab/prometheus/"
  fs_path              = "${path.module}/prometheus-configs"
  config               = templatefile(
    "${path.module}/prometheus-configs/prometheus.yml.tpl",
    {
      alertmanager_enabled = fileexists("${path.module}/../shared/alertmanager_ca.crt")
    }
  )
  node_exporter_jobs   = [
    {
      tag                        = "etcd"
      expected_count             = 3
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
      alert_labels               = {
        org = "ferlab"
      }
    },
    {
      tag                        = "coredns"
      expected_count             = 1
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
      alert_labels               = {
        org = "ferlab"
      }
    },
    {
      tag                        = "prometheus"
      expected_count             = 1
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
      alert_labels               = {
        org = "ferlab"
      }
    },
    {
      tag                        = "alertmanager"
      expected_count             = 1
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
      alert_labels               = {
        org = "ferlab"
      }
    },
    {
      tag                        = "automation-server"
      expected_count             = 1
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
      alert_labels               = {
        org = "ferlab"
      }
    },
    {
      tag                        = "dhcp"
      expected_count             = 1
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
      alert_labels               = {
        org = "ferlab"
      }
    }
  ]
  terracd_jobs   = [
    {
      tag                      = "time-in-files"
      plan_interval_threshold  = 60
      apply_interval_threshold = 600
      unit                     = "minute"
      alert_labels               = {
        org = "ferlab"
      }
    }
  ]
}