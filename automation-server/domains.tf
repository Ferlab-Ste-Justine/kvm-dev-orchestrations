module "automation_server_domain" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain = "automation.ferlab.lan"
  key_prefix = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.lan."
  a_records = [
    {
      prefix = ""
      ip = local.params.automation_server.address.ip
    },
  ]
}