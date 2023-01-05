resource "netaddr_address_ipv4" "coredns" {
    range_id = netaddr_range_ipv4.ip.id
    name     = "ferlab-coredns-1"
    hardcoded_address = local.params.assignable_ip_range.start
}

resource "netaddr_address_mac" "coredns" {
    range_id = netaddr_range_mac.mac.id
    name     = "ferlab-coredns-1"
}