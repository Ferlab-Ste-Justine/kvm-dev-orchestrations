resource "netaddr_address_ipv4" "vault_servers" {
    count      = local.params.vault.servers.count
    range_id   = netaddr_range_ipv4.ip.id
    name       = "ferlab-vault-${count.index + 1}"
    depends_on = [netaddr_address_ipv4.coredns]
}

resource "netaddr_address_mac" "vault_servers" {
    count    = local.params.vault.servers.count
    range_id = netaddr_range_mac.mac.id
    name     = "ferlab-vault-${count.index + 1}"
}

resource "netaddr_address_ipv4" "vault_lb" {
    count      = 1
    range_id   = netaddr_range_ipv4.ip.id
    name       = "ferlab-vault-lb-${count.index + 1}"
    depends_on = [netaddr_address_ipv4.coredns]
}

resource "netaddr_address_mac" "vault_lb" {
    count    = 1
    range_id = netaddr_range_mac.mac.id
    name     = "ferlab-vault-lb-${count.index + 1}"
}

resource "netaddr_address_ipv4" "vault_lb_tunnel" {
    count      = local.params.vault.load_balancer.tunnel ? 1 : 0
    range_id   = netaddr_range_ipv4.ip.id
    name       = "ferlab-vault-lb-tunnel"
    depends_on = [netaddr_address_ipv4.coredns]
}

resource "netaddr_address_mac" "vault_lb_tunnel" {
    count    = local.params.vault.load_balancer.tunnel ? 1 : 0
    range_id = netaddr_range_mac.mac.id
    name     = "ferlab-vault-lb-tunnel"
}