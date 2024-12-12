resource "random_bytes" "key_1" {
  length = 32
}

resource "local_file" "master_key_1" {
  content         = random_bytes.key_1.hex
  file_permission = "0600"
  filename        = "${path.module}/../work-env/etcd-backup-master-1.key"
  depends_on = [
    null_resource.setup
  ]
}

resource "random_bytes" "key_2" {
  length = 32
}

resource "local_file" "master_key_2" {
  content         = random_bytes.key_2.hex
  file_permission = "0600"
  filename        = "${path.module}/../work-env/etcd-backup-master-2.key"
  depends_on = [
    null_resource.setup
  ]
}