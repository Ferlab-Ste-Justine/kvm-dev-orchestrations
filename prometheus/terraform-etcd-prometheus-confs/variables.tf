variable "node_exporter_jobs" {
  description = "List of node export jobs."
  type = list(object({
    label                      = string
    expected_count             = number
    memory_usage_threshold     = number
    cpu_usage_threshold        = number
    disk_space_usage_threshold = number
    disk_io_usage_threshold    = number
  }))
  default = []
}

variable "alertmanager_enabled" {
  description = "Indicates whether the alertmanager is enabled."
  type = string
}

variable "fs_path" {
  description = "Local filesystem path where config files should be synchronized from."
  type = string
}

variable "etcd_key_prefix" {
  description = "Etcd prefix to sync configuration files in."
  type = string
}