resource "netaddr_range_ipv4" "ip" {
    key_prefix = "/ferlab/netaddr/ip/"
    first_address = local.params.assignable_ip_range.start
    last_address = local.params.assignable_ip_range.end
}

resource "netaddr_range_mac" "mac" {
    key_prefix = "/ferlab/netaddr/mac/"
    first_address = local.params.assignable_mac_range.start
    last_address = local.params.assignable_mac_range.end
}