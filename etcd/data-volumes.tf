resource "libvirt_volume" "etcd_1_data" {
  count            = local.params.etcd.data_volumes ? 1 : 0
  name             = "ferlab-etcd-1-data"
  pool             = "default"
  size             = 1 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "etcd_2_data" {
  count            = local.params.etcd.data_volumes ? 1 : 0
  name             = "ferlab-etcd-2-data"
  pool             = "default"
  size             = 1 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "etcd_3_data" {
  count            = local.params.etcd.data_volumes ? 1 : 0
  name             = "ferlab-etcd-3-data"
  pool             = "default"
  size             = 1 * 1024 * 1024 * 1024
  format           = "qcow2"
}