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

resource "netaddr_address_ipv4" "coredns" {
    range_id = data.netaddr_range_ipv4.ip.id
    name     = "ferlab-coredns-1"
    hardcoded_address = local.params.network.static_range.start
}

resource "netaddr_address_mac" "coredns" {
    range_id = data.netaddr_range_mac.mac.id
    name     = "ferlab-coredns-1"
}