resource "libvirt_volume" "alertmanager_data" {
  count  = local.params.alertmanager.data_volumes ? 2 : 0
  name   = "ferlab-alertmanager-${count.index + 1}-data"
  pool   = "default"
  size   = 10 * 1024 * 1024 * 1024
  format = "qcow2"
}