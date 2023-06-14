resource "libvirt_volume" "minio_1_1_data" {
  name             = "ferlab-minio-1-1-data"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_1_2_data" {
  name             = "ferlab-minio-1-2-data"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_2_1_data" {
  name             = "ferlab-minio-2-1-data"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_2_2_data" {
  name             = "ferlab-minio-2-2-data"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_3_1_data" {
  name             = "ferlab-minio-3-1-data"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_3_2_data" {
  name             = "ferlab-minio-3-2-data"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_4_1_data" {
  name             = "ferlab-minio-4-1-data"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "minio_4_2_data" {
  name             = "ferlab-minio-4-2-data"
  pool             = "default"
  size             = 2 * 1024 * 1024 * 1024
  format           = "qcow2"
}