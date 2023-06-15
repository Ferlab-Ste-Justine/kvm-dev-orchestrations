resource "libvirt_volume" "dhcp_data" {
  count            = local.params.dhcp.data_volumes ? 1 : 0
  name             = "ferlab-dhcp-data"
  pool             = "default"
  size             = 128 * 1024 * 1024
  format           = "qcow2"
}