module "coredns_domain" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain = "ns.ferlab.lan"
  key_prefix = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.lan."
  a_records = [
    {
      prefix = ""
      ip = netaddr_address_ipv4.coredns.address
    },
  ]
}