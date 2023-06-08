/*resource "netaddr_address_ipv4" "postgres" {
    count      = 3
    range_id   = netaddr_range_ipv4.ip.id
    name       = "ferlab-postgres-${count.index + 1}"
    depends_on = [netaddr_address_ipv4.coredns]
}

resource "netaddr_address_mac" "postgres" {
    count    = 3
    range_id = netaddr_range_mac.mac.id
    name     = "ferlab-postgres-${count.index + 1}"
}

resource "netaddr_address_ipv4" "postgres_lb" {
    range_id   = netaddr_range_ipv4.ip.id
    name       = "ferlab-postgres-lb-1"
    depends_on = [netaddr_address_ipv4.coredns]
}

resource "netaddr_address_mac" "postgres_lb" {
    range_id = netaddr_range_mac.mac.id
    name     = "ferlab-postgres-lb-1"
}*/