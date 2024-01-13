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

resource "netaddr_address_ipv4" "minio" {
    count    = local.params.minio.ferio_expand_server_pools ? 8 : 4
    range_id = data.netaddr_range_ipv4.ip.id
    name     = "ferlab-minio-${count.index + 1}"
}

resource "netaddr_address_mac" "minio" {
    count    = local.params.minio.ferio_expand_server_pools ? 8 : 4
    range_id = data.netaddr_range_mac.mac.id
    name     = "ferlab-minio-${count.index + 1}"
}