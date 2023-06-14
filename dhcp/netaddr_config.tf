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
    range_id = data.netaddr_range_ipv4.ip.id
    name     = "ferlab-coredns-1"
}

data "netaddr_address_mac" "coredns" {
    range_id = data.netaddr_range_mac.mac.id
    name     = "ferlab-coredns-1"
}

resource "netaddr_address_ipv4" "dhcp" {
    range_id = data.netaddr_range_ipv4.ip.id
    name     = "ferlab-dhcp"
}

resource "netaddr_address_mac" "dhcp" {
    range_id = data.netaddr_range_mac.mac.id
    name     = "ferlab-dhcp"
}