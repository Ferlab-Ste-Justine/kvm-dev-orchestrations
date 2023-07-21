module "alertmanager_domain" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain = "alertmanager.ferlab.lan"
  key_prefix = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.lan."
  a_records = concat(
    [
      for alertmanager in netaddr_address_ipv4.alertmanager: {
        prefix = ""
        ip = alertmanager.address
      }
    ],
    [
      for idx, alertmanager in netaddr_address_ipv4.alertmanager: {
        prefix = "server-${idx + 1}"
        ip = alertmanager.address
      }
    ]
  )
}