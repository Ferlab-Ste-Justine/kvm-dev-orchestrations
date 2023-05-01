module "vault_lb_domain" {
  source          = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain          = "vault.ferlab.local"
  key_prefix      = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.local."
  a_records = concat(
    [for lb in data.netaddr_address_ipv4.vault_lb: {
      prefix = ""
      ip = lb.address
    }],
    [for server in data.netaddr_address_ipv4.vault_servers: {
      prefix = "servers"
      ip     = server.address
    }]
  )
}

module "vault_domain" {
  count           = local.params.vault.servers.count
  source          = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain          = "vault-server-${count.index + 1}.ferlab.local"
  key_prefix      = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.local."
  a_records       = concat(
    [{
      prefix = ""
      ip     = element(data.netaddr_address_ipv4.vault_servers.*.address, count.index)
    }]
  )
}