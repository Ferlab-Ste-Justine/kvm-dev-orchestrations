resource "libvirt_volume" "postgres_1_data" {
  count            = local.params.postgres.servers.data_volumes ? 1 : 0
  name             = "ferlab-postgres-1-data"
  pool             = "default"
  size             = 1 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "postgres_2_data" {
  count            = local.params.postgres.servers.data_volumes ? 1 : 0
  name             = "ferlab-postgres-2-data"
  pool             = "default"
  size             = 1 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "postgres_3_data" {
  count            = local.params.postgres.servers.data_volumes ? 1 : 0
  name             = "ferlab-postgres-3-data"
  pool             = "default"
  size             = 1 * 1024 * 1024 * 1024
  format           = "qcow2"
}