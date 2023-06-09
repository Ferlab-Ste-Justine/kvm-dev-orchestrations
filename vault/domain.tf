module "vault_lb_tunnel_domain" {
  source          = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain          = "vault-tunnel.ferlab.lan"
  key_prefix      = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.lan."
  a_records = concat(
    [for lb in netaddr_address_ipv4.vault_lb_tunnel: {
      prefix = ""
      ip     = "127.0.0.1"
    }]
  )
}

module "vault_lb_domain" {
  source          = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain          = "vault.ferlab.lan"
  key_prefix      = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.lan."
  a_records = concat(
    [for lb in netaddr_address_ipv4.vault_lb: {
      prefix = ""
      ip = lb.address
    }],
    [for server in netaddr_address_ipv4.vault_servers: {
      prefix = "servers"
      ip     = server.address
    }]
  )
}

module "vault_domain" {
  count           = local.params.vault.servers.count
  source          = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain          = "vault-server-${count.index + 1}.ferlab.lan"
  key_prefix      = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.lan."
  a_records       = concat(
    [{
      prefix = ""
      ip     = element(netaddr_address_ipv4.vault_servers.*.address, count.index)
    }]
  )
}