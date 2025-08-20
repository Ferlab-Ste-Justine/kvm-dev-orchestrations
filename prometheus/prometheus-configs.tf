module "prometheus_confs" {
  source               = "./terraform-etcd-prometheus-configuration"
  etcd_key_prefix      = "/ferlab/prometheus/"
  config               = templatefile(
    "${path.module}/prometheus-configs/prometheus.yml.tpl",
    {
      alertmanager_enabled          = fileexists("${path.module}/../shared/alertmanager_ca.crt")
      kubernetes_cluster_federation = local.params.prometheus.kubernetes_cluster_federation
      minio_cluster_monitoring      = local.params.prometheus.minio_cluster_monitoring
      starrocks_cluster_monitoring  = local.params.prometheus.starrocks_cluster_monitoring
      etcd_addresses                = local.params.etcd.addresses
      host_ip                       = local.host_params.ip
    }
  )
  heartbeat = {
    hour         = 12
    minute       = 00
    alert_labels = {
      org = "ferlab"
    }
  }
  node_exporter_jobs   = [
    {
      tag                        = "etcd"
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      expected_disks_count       = -1
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
      alert_labels               = {
        org = "ferlab"
      }
    },
    {
      tag                        = "coredns"
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      expected_disks_count       = 1
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
      alert_labels               = {
        org = "ferlab"
      }
    },
    {
      tag                        = "prometheus"
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      expected_disks_count       = -1
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
      alert_labels               = {
        org = "ferlab"
      }
    },
    {
      tag                        = "alertmanager"
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      expected_disks_count       = -1
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
      alert_labels               = {
        org = "ferlab"
      }
    },
    {
      tag                        = "automation-server"
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      expected_disks_count       = -1
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
      alert_labels               = {
        org = "ferlab"
      }
    },
    {
      tag                        = "dhcp"
      memory_usage_threshold     = 90
      cpu_usage_threshold        = 90
      expected_disks_count       = -1
      disk_space_usage_threshold = 90
      disk_io_usage_threshold    = 90
      alert_labels               = {
        org = "ferlab"
      }
    }
  ]
  terracd_jobs = [
    /*{
      tag                      = "time-in-files"
      plan_interval_threshold  = 60
      apply_interval_threshold = 600
      unit                     = "minute"
      alert_labels             = {
        org = "ferlab"
      }
    },*/
    {
      tag                      = "terracd-test"
      run_interval_threshold   = 60
      apply_interval_threshold = 600
      failure_time_frame       = 30
      provider_use_time_frame  = 60
      unit                     = "minute"
      alert_labels             = {
        org = "ferlab"
      }
    }
  ]
  kubernetes_cluster_jobs = [
    {
      tag = "local"
      expected_services = [
        /*{
          name                 = "mock-minio"
          namespace            = "default"
          expected_min_count   = 2
          expected_start_delay = 60
          alert_labels         = {
            org = "ferlab"
          }
        }*/
      ]
    }
  ]
  minio_cluster_jobs = [
    {
      tag = "local"
    }
  ]
  etcd_exporter_jobs   = [
    {
      tag            = "ops"
      members_count  = 3
      max_learn_time = "15m"
      max_db_size    = 8
      alert_labels   = {
        org = "ferlab"
      }
    }
  ]
  patroni_exporter_jobs   = [
    {
      tag                     = "ops"
      members_count           = 3
      synchronous_replication = true
      patroni_version         = "4.0.4"
      postgres_version        = "14.0.15"
      max_wal_divergence      = 1
      alert_labels            = {
        org = "ferlab"
      }
    }
  ]
}