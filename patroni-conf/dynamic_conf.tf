resource "patroni_dynamic_config" "config" {
  failsafe_mode = false
  max_timelines_history = 1000
  maximum_lag_on_failover = 10 * 1024 * 1024
  maximum_lag_on_syncnode = 10 * 1024 * 1024
  postgresql = {
    parameters = {
      checkpoint_completion_target = "0.9"
      checkpoint_timeout = "30min"
      checkpoint_warning = "10min"
      effective_cache_size = "2GB"
      log_directory = "/var/log/postgresql"
      maintenance_work_mem = "128MB"
      max_connections = "100"
      max_wal_size = "2GB"
      shared_buffers = "1GB"
      ssl = "true"
      ssl_cert_file = "/etc/postgres/tls/server.crt"
      ssl_key_file = "/etc/postgres/tls/server.key"
      work_mem = "3MB"
      wal_log_hints = "on"
    }
    //pg_hba = [..]
    //pg_ident = [..]
    use_pg_rewind = true
    use_slots = true
  }
  primary_start_timeout = 300
  primary_stop_timeout = 300
  retry_timeout = 10
  synchronous_mode = true
  synchronous_mode_strict = true
  synchronous_node_count = 1
  ttl = 60
}