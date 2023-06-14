provider "etcd" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert = "${path.module}/../shared/etcd-ca.pem"
  username = "root"
  password = file("${path.module}/../shared/etcd-root_password")
}

data "etcd_prefix_range_end" "pxe" {
  key = "/ferlab/pxe/"
}

resource "etcd_role" "pxe" {
  name = "pxe"

  permissions {
    permission = "readwrite"
    key = data.etcd_prefix_range_end.pxe.key
    range_end = data.etcd_prefix_range_end.pxe.range_end
  }
}

resource "random_password" "pxe_etcd_password" {
  length           = 16
  special          = false
}

resource "etcd_user" "pxe" {
  username = "pxe"
  password = random_password.pxe_etcd_password.result
  roles = [etcd_role.pxe.name]
}