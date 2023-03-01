resource "netaddr_address_ipv4" "nfs" {
    range_id   = netaddr_range_ipv4.ip.id
    name       = "ferlab-nfs"
    depends_on = [netaddr_address_ipv4.coredns]
}

resource "netaddr_address_mac" "nfs" {
    range_id = netaddr_range_mac.mac.id
    name     = "ferlab-nfs"
}