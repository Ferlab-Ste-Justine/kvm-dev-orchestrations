resource "libvirt_volume" "minio_1_1_data" {
  name             = "ferlab-minio-1-1-data"
  pool             = "default"
  size             = local.params.minio.data_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_1_2_data" {
  name             = "ferlab-minio-1-2-data"
  pool             = "default"
  size             = local.params.minio.data_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_2_1_data" {
  name             = "ferlab-minio-2-1-data"
  pool             = "default"
  size             = local.params.minio.data_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_2_2_data" {
  name             = "ferlab-minio-2-2-data"
  pool             = "default"
  size             = local.params.minio.data_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_3_1_data" {
  name             = "ferlab-minio-3-1-data"
  pool             = "default"
  size             = local.params.minio.data_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_3_2_data" {
  name             = "ferlab-minio-3-2-data"
  pool             = "default"
  size             = local.params.minio.data_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_4_1_data" {
  name             = "ferlab-minio-4-1-data"
  pool             = "default"
  size             = local.params.minio.data_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_4_2_data" {
  name             = "ferlab-minio-4-2-data"
  pool             = "default"
  size             = local.params.minio.data_disk_capacity * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_1_queue" {
  name             = "ferlab-minio-1-queue"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024  # 2 GiB
  format           = "qcow2"
}

resource "libvirt_volume" "minio_2_queue" {
  name             = "ferlab-minio-2-queue"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024  # 2 GiB
  format           = "qcow2"
}

resource "libvirt_volume" "minio_3_queue" {
  name             = "ferlab-minio-3-queue"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024  # 2 GiB
  format           = "qcow2"
}

resource "libvirt_volume" "minio_4_queue" {
  name             = "ferlab-minio-4-queue"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024  # 2 GiB
  format           = "qcow2"
}
