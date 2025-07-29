module "starrocks_domain" {
  source          = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain          = "starrocks.ferlab.lan"
  key_prefix      = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.lan."
  a_records       = concat(
    [for node in netaddr_address_ipv4.fe_nodes: {
      prefix = ""
      ip     = node.address
    }],
    [for node in netaddr_address_ipv4.fe_nodes: {
      prefix = "frontends"
      ip     = node.address
    }],
    [for node in netaddr_address_ipv4.be_nodes: {
      prefix = "backends"
      ip     = node.address
    }]
  )
}

module "starrocks_fe_domain" {
  count           = local.params.starrocks.fe_nodes.count
  source          = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain          = "starrocks-server-fe-${count.index + 1}.ferlab.lan"
  key_prefix      = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.lan."
  a_records       = concat(
    [{
      prefix = ""
      ip     = element(netaddr_address_ipv4.fe_nodes.*.address, count.index)
    }]
  )
}

module "starrocks_be_domain" {
  count           = local.params.starrocks.be_nodes.count
  source          = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain          = "starrocks-server-be-${count.index + 1}.ferlab.lan"
  key_prefix      = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.lan."
  a_records       = concat(
    [{
      prefix = ""
      ip     = element(netaddr_address_ipv4.be_nodes.*.address, count.index)
    }]
  )
}
