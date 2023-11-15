variable "terracd_jobs" {
  description = "List of terracd jobs"
  type = list(object({
    label                    = string
    plan_interval_threshold  = number
    apply_interval_threshold = number
    unit                     = string
  }))
  default = []

  validation {
    condition     = alltrue([for job in var.terracd_jobs: contains(["minute", "hour"], job.unit)])
    error_message = "Units for terracd_jobs must be 'minute' or 'hour'"
  }
}

variable "node_exporter_jobs" {
  description = "List of node exporter jobs"
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

variable "config" {
  description = "Content of your prometheus main configuration file."
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