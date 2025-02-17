data "netaddr_range_ipv4" "ip" {
    key_prefix = "/ferlab/netaddr/ip/"
}

data "netaddr_address_ipv4" "k8_lb" {
    range_id = data.netaddr_range_ipv4.ip.id
    name     = "ferlab-k8-lb-1"
}