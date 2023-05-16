resource "libvirt_volume" "nfs_data" {
  count            = local.params.nfs.data_volumes ? 1 : 0
  name             = "ferlab-nfs-data"
  pool             = "default"
  size             = 1 * 1024 * 1024 * 1024
  format           = "qcow2"
}