provider "netaddr" {
  endpoints = join(",", [for etcd in local.params.etcd_addresses: "${etcd.ip}:2379"])
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

data "netaddr_address_ipv4" "k8_masters" {
    count = local.params.k8_masters_count
    range_id = data.netaddr_range_ipv4.ip.id
    name     = "ferlab-k8-master-${count.index + 1}"
}

data "netaddr_address_mac" "k8_masters" {
    count = local.params.k8_masters_count
    range_id = data.netaddr_range_mac.mac.id
    name     = "ferlab-k8-master-${count.index + 1}"
}

data "netaddr_address_ipv4" "k8_workers" {
    count = local.params.k8_workers_count
    range_id = data.netaddr_range_ipv4.ip.id
    name     = "ferlab-k8-worker-${count.index + 1}"
}

data "netaddr_address_mac" "k8_workers" {
    count = local.params.k8_workers_count
    range_id = data.netaddr_range_mac.mac.id
    name     = "ferlab-k8-worker-${count.index + 1}"
}

data "netaddr_address_ipv4" "k8_lb" {
    count = 1
    range_id = data.netaddr_range_ipv4.ip.id
    name     = "ferlab-k8-lb-${count.index + 1}"
}

data "netaddr_address_mac" "k8_lb" {
    count = 1
    range_id = data.netaddr_range_mac.mac.id
    name     = "ferlab-k8-lb-${count.index + 1}"
}

data "netaddr_address_ipv4" "k8_bastion" {
    count = 1
    range_id = data.netaddr_range_ipv4.ip.id
    name     = "ferlab-k8-bastion-${count.index + 1}"
}

data "netaddr_address_mac" "k8_bastion" {
    count = 1
    range_id = data.netaddr_range_mac.mac.id
    name     = "ferlab-k8-bastion-${count.index + 1}"
}