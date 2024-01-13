resource "libvirt_volume" "minio_5_1_data" {
  count            = local.params.minio.ferio_expand_server_pools ? 1 : 0
  name             = "ferlab-minio-5-1-data"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_5_2_data" {
  count            = local.params.minio.ferio_expand_server_pools ? 1 : 0
  name             = "ferlab-minio-5-2-data"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_6_1_data" {
  count            = local.params.minio.ferio_expand_server_pools ? 1 : 0
  name             = "ferlab-minio-6-1-data"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_6_2_data" {
  count            = local.params.minio.ferio_expand_server_pools ? 1 : 0
  name             = "ferlab-minio-6-2-data"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_7_1_data" {
  count            = local.params.minio.ferio_expand_server_pools ? 1 : 0
  name             = "ferlab-minio-7-1-data"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_7_2_data" {
  count            = local.params.minio.ferio_expand_server_pools ? 1 : 0
  name             = "ferlab-minio-7-2-data"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_8_1_data" {
  count            = local.params.minio.ferio_expand_server_pools ? 1 : 0
  name             = "ferlab-minio-8-1-data"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_8_2_data" {
  count            = local.params.minio.ferio_expand_server_pools ? 1 : 0
  name             = "ferlab-minio-8-2-data"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024
  format           = "qcow2"
}