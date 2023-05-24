module "prometheus_domain" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain = "prometheus.ferlab.lan"
  key_prefix = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.lan."
  a_records = [
    {
      prefix = ""
      ip = data.netaddr_address_ipv4.prometheus.0.address
    },
  ]
}

module "etcd_scape_domain" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain = "etcd.ferlab.lan"
  key_prefix = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.lan."
  a_records = [for etcd in local.params.etcd.addresses: {
    prefix = ""
    ip = etcd.ip
  }]
}