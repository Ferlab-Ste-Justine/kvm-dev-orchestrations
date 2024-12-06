provider "etcd" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert   = "${path.module}/../shared/etcd-ca.pem"
  username  = "root"
  password  = file("${path.module}/../shared/etcd-root_password")
}

module "smrtlink_domain" {
  source          = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain          = "smrtlink.ferlab.lan"
  key_prefix      = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.lan."
  a_records = concat(
    [{
      prefix = ""
      ip = netaddr_address_ipv4.smrtlink.address
    }]
  )
}
