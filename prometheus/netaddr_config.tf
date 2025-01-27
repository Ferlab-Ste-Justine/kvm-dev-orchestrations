provider "netaddr" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert = "${path.module}/../shared/etcd-ca.pem"
  username = !local.params.etcd.cert_auth ? "root" : null
  password = !local.params.etcd.cert_auth ? file("${path.module}/../shared/etcd-root_password") : null
  cert     = local.params.etcd.cert_auth ? "${path.module}/../shared/etcd-root.crt" : null
  key      = local.params.etcd.cert_auth ? "${path.module}/../shared/etcd-root.key" : null
}

data "netaddr_range_ipv4" "ip" {
    key_prefix = "/ferlab/netaddr/ip/"
}

data "netaddr_range_mac" "mac" {
    key_prefix = "/ferlab/netaddr/mac/"
}

data "netaddr_address_ipv4" "coredns" {
    count = 1
    range_id = data.netaddr_range_ipv4.ip.id
    name     = "ferlab-coredns-${count.index + 1}"
}

resource "netaddr_address_ipv4" "prometheus" {
    count = 1
    range_id = data.netaddr_range_ipv4.ip.id
    name     = "ferlab-prometheus-${count.index + 1}"
}

resource "netaddr_address_mac" "prometheus" {
    count = 1
    range_id = data.netaddr_range_mac.mac.id
    name     = "ferlab-prometheus-${count.index + 1}"
}