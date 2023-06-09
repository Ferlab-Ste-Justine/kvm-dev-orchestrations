resource "libvirt_volume" "prometheus_1_data" {
  count            = local.params.prometheus.data_volumes ? 1 : 0
  name             = "ferlab-prometheus-1-data"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  format           = "qcow2"
}