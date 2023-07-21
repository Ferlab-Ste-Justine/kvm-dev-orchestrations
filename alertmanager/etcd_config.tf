provider "etcd" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert = "${path.module}/../shared/etcd-ca.pem"
  username = "root"
  password = file("${path.module}/../shared/etcd-root_password")
}

data "etcd_prefix_range_end" "alertmanager" {
  key = "/ferlab/alertmanager/"
}

resource "etcd_role" "alertmanager" {
  name = "alertmanager"

  permissions {
    permission = "readwrite"
    key = data.etcd_prefix_range_end.alertmanager.key
    range_end = data.etcd_prefix_range_end.alertmanager.range_end
  }
}

resource "random_password" "alertmanager_etcd_password" {
  length           = 16
  special          = false
}

resource "etcd_user" "alertmanager" {
  username = "alertmanager"
  password = random_password.alertmanager_etcd_password.result
  roles = [etcd_role.alertmanager.name]
}