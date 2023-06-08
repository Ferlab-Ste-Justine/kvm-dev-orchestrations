resource "netaddr_range_ipv4" "ip" {
    key_prefix = "/ferlab/netaddr/ip/"
    first_address = local.params.network.static_range.start
    last_address = local.params.network.static_range.end
}

resource "netaddr_range_mac" "mac" {
    key_prefix = "/ferlab/netaddr/mac/"
    first_address = local.params.mac_range.start
    last_address = local.params.mac_range.end
}