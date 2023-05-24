provider "etcd" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert = "${path.module}/../shared/etcd-ca.pem"
  username = "root"
  password = file("${path.module}/../shared/etcd-root_password")
}

data "etcd_prefix_range_end" "prometheus" {
  key = "/ferlab/prometheus/"
}

resource "etcd_role" "prometheus" {
  name = "prometheus"

  permissions {
    permission = "readwrite"
    key = data.etcd_prefix_range_end.prometheus.key
    range_end = data.etcd_prefix_range_end.prometheus.range_end
  }
}

resource "random_password" "prometheus_etcd_password" {
  length           = 16
  special          = false
}

resource "etcd_user" "prometheus" {
  username = "prometheus"
  password = random_password.prometheus_etcd_password.result
  roles = [etcd_role.prometheus.name]
}