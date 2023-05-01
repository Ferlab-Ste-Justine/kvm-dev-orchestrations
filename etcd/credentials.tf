module "etcd_ca" {
  source = "../ca"
  common_name = "etcd"
}

resource "local_file" "etcd_ca_cert" {
  content         = module.etcd_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/etcd-ca.pem"
}

resource "local_file" "etcd_ca_key" {
  content         = module.etcd_ca.key
  file_permission = "0600"
  filename        = "${path.module}/../shared/etcd-ca.key"
}

resource "local_file" "etcd_ca_key_algorithm" {
  content         = module.etcd_ca.key_algorithm
  file_permission = "0600"
  filename        = "${path.module}/../shared/etcd-ca_key_algorithm"
}

resource "random_password" "etcd_root_password" {
  length           = 16
  special          = false
}

resource "local_file" "etcd_root_password" {
  content         = random_password.etcd_root_password.result
  file_permission = "0600"
  filename        = "${path.module}/../shared/etcd-root_password"
}