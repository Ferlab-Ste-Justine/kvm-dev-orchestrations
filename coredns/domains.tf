module "coredns_domain" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain = "ns.ferlab.local"
  key_prefix = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.local."
  a_records = [
    {
      prefix = ""
      ip = data.netaddr_address_ipv4.coredns.0.address
    },
  ]
}