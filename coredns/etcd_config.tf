provider "etcd" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert = "${path.module}/../shared/etcd-ca.pem"
  username = "root"
  password = file("${path.module}/../shared/etcd-root_password")
}

data "etcd_prefix_range_end" "coredns" {
  key = "/ferlab/coredns/"
}

resource "etcd_role" "coredns" {
  name = "coredns"

  permissions {
    permission = "readwrite"
    key = data.etcd_prefix_range_end.coredns.key
    range_end = data.etcd_prefix_range_end.coredns.range_end
  }
}

resource "random_password" "coredns_etcd_password" {
  length           = 16
  special          = false
}

resource "etcd_user" "coredns" {
  username = "coredns"
  password = random_password.coredns_etcd_password.result
  roles = [etcd_role.coredns.name]
}