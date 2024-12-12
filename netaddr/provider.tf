locals {
  params = jsondecode(file("${path.module}/../shared/params.json"))
}

provider "netaddr" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert = "${path.module}/../shared/etcd-ca.pem"
  username = !local.params.etcd.cert_auth ? "root" : null
  password = !local.params.etcd.cert_auth ? file("${path.module}/../shared/etcd-root_password") : null
  cert     = local.params.etcd.cert_auth ? "${path.module}/../shared/etcd-root.crt" : null
  key      = local.params.etcd.cert_auth ? "${path.module}/../shared/etcd-root.key" : null
  strict = false
}
