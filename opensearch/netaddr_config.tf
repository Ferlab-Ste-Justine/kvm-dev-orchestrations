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

resource "netaddr_address_ipv4" "masters" {
  count    = local.params.opensearch.masters.count
  range_id = data.netaddr_range_ipv4.ip.id
  name     = "ferlab-opensearch-master-${count.index + 1}"
}

resource "netaddr_address_mac" "masters" {
  count    = local.params.opensearch.masters.count
  range_id = data.netaddr_range_mac.mac.id
  name     = "ferlab-opensearch-master-${count.index + 1}"
}

resource "netaddr_address_ipv4" "workers" {
  count    = local.params.opensearch.workers.count
  range_id = data.netaddr_range_ipv4.ip.id
  name     = "ferlab-opensearch-worker-${count.index + 1}"
}

resource "netaddr_address_mac" "workers" {
  count    = local.params.opensearch.workers.count
  range_id = data.netaddr_range_mac.mac.id
  name     = "ferlab-opensearch-worker-${count.index + 1}"
}

resource "netaddr_address_ipv4" "audit_masters" {
  count    = local.audit_enabled ? local.params.opensearch.audit.masters.count : 0
  range_id = data.netaddr_range_ipv4.ip.id
  name     = "ferlab-opensearch-audit-master-${count.index + 1}"
}

resource "netaddr_address_mac" "audit_masters" {
  count    = local.audit_enabled ? local.params.opensearch.audit.masters.count : 0
  range_id = data.netaddr_range_mac.mac.id
  name     = "ferlab-opensearch-audit-master-${count.index + 1}"
}

resource "netaddr_address_ipv4" "audit_workers" {
  count    = local.audit_enabled ? local.params.opensearch.audit.workers.count : 0
  range_id = data.netaddr_range_ipv4.ip.id
  name     = "ferlab-opensearch-audit-worker-${count.index + 1}"
}

resource "netaddr_address_mac" "audit_workers" {
  count    = local.audit_enabled ? local.params.opensearch.audit.workers.count : 0
  range_id = data.netaddr_range_mac.mac.id
  name     = "ferlab-opensearch-audit-worker-${count.index + 1}"
}
