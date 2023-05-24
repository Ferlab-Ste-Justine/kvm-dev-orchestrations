provider "etcd" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert = "${path.module}/../shared/etcd-ca.pem"
  username = "root"
  password = file("${path.module}/../shared/etcd-root_password")
}

module "nfs_domain" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain = "nfs.ferlab.lan"
  key_prefix = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.lan."
  a_records = concat(
    [{
      prefix = ""
      ip = data.netaddr_address_ipv4.nfs.address
    }]
  )
}