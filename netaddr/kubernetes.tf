/*resource "netaddr_address_ipv4" "k8_masters" {
    count = 3
    range_id = netaddr_range_ipv4.ip.id
    name     = "ferlab-k8-master-${count.index + 1}"
    depends_on = [netaddr_address_ipv4.coredns]
}

resource "netaddr_address_mac" "k8_masters" {
    count = 3
    range_id = netaddr_range_mac.mac.id
    name     = "ferlab-k8-master-${count.index + 1}"
}

resource "netaddr_address_ipv4" "k8_workers" {
    count = 3
    range_id = netaddr_range_ipv4.ip.id
    name     = "ferlab-k8-worker-${count.index + 1}"
    depends_on = [netaddr_address_ipv4.coredns]
}

resource "netaddr_address_mac" "k8_workers" {
    count = 3
    range_id = netaddr_range_mac.mac.id
    name     = "ferlab-k8-worker-${count.index + 1}"
}

resource "netaddr_address_ipv4" "k8_lb" {
    count = 1
    range_id = netaddr_range_ipv4.ip.id
    name     = "ferlab-k8-lb-${count.index + 1}"
    depends_on = [netaddr_address_ipv4.coredns]
}

resource "netaddr_address_mac" "k8_lb" {
    count = 1
    range_id = netaddr_range_mac.mac.id
    name     = "ferlab-k8-lb-${count.index + 1}"
}

resource "netaddr_address_ipv4" "k8_bastion" {
    count = 1
    range_id = netaddr_range_ipv4.ip.id
    name     = "ferlab-k8-bastion-${count.index + 1}"
    depends_on = [netaddr_address_ipv4.coredns]
}

resource "netaddr_address_mac" "k8_bastion" {
    count = 1
    range_id = netaddr_range_mac.mac.id
    name     = "ferlab-k8-bastion-${count.index + 1}"
}*/