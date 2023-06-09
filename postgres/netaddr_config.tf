provider "netaddr" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert = "${path.module}/../shared/etcd-ca.pem"
  username = "root"
  password = file("${path.module}/../shared/etcd-root_password")
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

resource "netaddr_address_ipv4" "postgres_lb" {
    count = 1
    range_id = data.netaddr_range_ipv4.ip.id
    name     = "ferlab-postgres-lb-${count.index + 1}"
}

resource "netaddr_address_mac" "postgres_lb" {
    count = 1
    range_id = data.netaddr_range_mac.mac.id
    name     = "ferlab-postgres-lb-${count.index + 1}"
}

resource "netaddr_address_ipv4" "postgres" {
    count    = 3
    range_id = data.netaddr_range_ipv4.ip.id
    name     = "ferlab-postgres-${count.index + 1}"
}

resource "netaddr_address_mac" "postgres" {
    count    = 3
    range_id = data.netaddr_range_mac.mac.id
    name     = "ferlab-postgres-${count.index + 1}"
}