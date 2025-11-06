resource "libvirt_volume" "minio_5_1_data" {
  count            = local.params.minio.extra_server_pool ? 1 : 0
  name             = "ferlab-minio-5-1-data"
  pool             = "default"
  size             = local.params.minio.data_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_5_2_data" {
  count            = local.params.minio.extra_server_pool ? 1 : 0
  name             = "ferlab-minio-5-2-data"
  pool             = "default"
  size             = local.params.minio.data_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_6_1_data" {
  count            = local.params.minio.extra_server_pool ? 1 : 0
  name             = "ferlab-minio-6-1-data"
  pool             = "default"
  size             = local.params.minio.data_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_6_2_data" {
  count            = local.params.minio.extra_server_pool ? 1 : 0
  name             = "ferlab-minio-6-2-data"
  pool             = "default"
  size             = local.params.minio.data_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_7_1_data" {
  count            = local.params.minio.extra_server_pool ? 1 : 0
  name             = "ferlab-minio-7-1-data"
  pool             = "default"
  size             = local.params.minio.data_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_7_2_data" {
  count            = local.params.minio.extra_server_pool ? 1 : 0
  name             = "ferlab-minio-7-2-data"
  pool             = "default"
  size             = local.params.minio.data_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_8_1_data" {
  count            = local.params.minio.extra_server_pool ? 1 : 0
  name             = "ferlab-minio-8-1-data"
  pool             = "default"
  size             = local.params.minio.data_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_8_2_data" {
  count            = local.params.minio.extra_server_pool ? 1 : 0
  name             = "ferlab-minio-8-2-data"
  pool             = "default"
  size             = local.params.minio.data_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_5_queue" {
  count            = local.params.minio.extra_server_pool ? 1 : 0
  name             = "ferlab-minio-5-queue"
  pool             = "default"
  size             = local.params.minio.queue_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_6_queue" {
  count            = local.params.minio.extra_server_pool ? 1 : 0
  name             = "ferlab-minio-6-queue"
  pool             = "default"
  size             = local.params.minio.queue_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_7_queue" {
  count            = local.params.minio.extra_server_pool ? 1 : 0
  name             = "ferlab-minio-7-queue"
  pool             = "default"
  size             = local.params.minio.queue_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_8_queue" {
  count            = local.params.minio.extra_server_pool ? 1 : 0
  name             = "ferlab-minio-8-queue"
  pool             = "default"
  size             = local.params.minio.queue_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}