module "domain" {
  source          = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain          = local.domain
  key_prefix      = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.lan."
  a_records = concat(
    [for server in concat(netaddr_address_ipv4.masters, netaddr_address_ipv4.workers) : {
      prefix = ""
      ip     = server.address
    }],
    [for master in netaddr_address_ipv4.masters : {
      prefix = "masters"
      ip     = master.address
    }],
    [for worker in netaddr_address_ipv4.workers : {
      prefix = "workers"
      ip     = worker.address
    }]
  )
}
