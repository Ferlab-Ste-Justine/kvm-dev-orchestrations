provider "netaddr" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert   = "${path.module}/../shared/etcd-ca.pem"
  username  = "root"
  password  = file("${path.module}/../shared/etcd-root_password")
}

data "netaddr_range_ipv4" "ip" {
  key_prefix = "/ferlab/netaddr/ip/"
}

data "netaddr_range_mac" "mac" {
  key_prefix = "/ferlab/netaddr/mac/"
}

data "netaddr_address_ipv4" "coredns" {
  count    = 1
  range_id = data.netaddr_range_ipv4.ip.id
  name     = "ferlab-coredns-${count.index + 1}"
}

resource "netaddr_address_ipv4" "vault_lb_tunnel" {
  count    = local.params.vault.load_balancer.tunnel ? 1 : 0
  range_id = data.netaddr_range_ipv4.ip.id
  name     = "ferlab-vault-lb-tunnel"
}

resource "netaddr_address_mac" "vault_lb_tunnel" {
  count    = local.params.vault.load_balancer.tunnel ? 1 : 0
  range_id = data.netaddr_range_mac.mac.id
  name     = "ferlab-vault-lb-tunnel"
}

resource "netaddr_address_ipv4" "vault_lb" {
  count    = 1
  range_id = data.netaddr_range_ipv4.ip.id
  name     = "ferlab-vault-lb-${count.index + 1}"
}

resource "netaddr_address_mac" "vault_lb" {
  count    = 1
  range_id = data.netaddr_range_mac.mac.id
  name     = "ferlab-vault-lb-${count.index + 1}"
}

resource "netaddr_address_ipv4" "vault_servers" {
  count    = local.params.vault.servers.count
  range_id = data.netaddr_range_ipv4.ip.id
  name     = "ferlab-vault-${count.index + 1}"
}

resource "netaddr_address_mac" "vault_servers" {
  count    = local.params.vault.servers.count
  range_id = data.netaddr_range_mac.mac.id
  name     = "ferlab-vault-${count.index + 1}"
}