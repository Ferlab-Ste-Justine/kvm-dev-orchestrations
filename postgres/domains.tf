provider "etcd" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert = "${path.module}/../shared/etcd-ca.pem"
  username = "root"
  password = file("${path.module}/../shared/etcd-root_password")
}

module "postgres_domain" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain = "postgres.ferlab.lan"
  key_prefix = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.lan."
  a_records = concat(
    [for lb in data.netaddr_address_ipv4.postgres: {
      prefix = "server"
      ip = lb.address
    }],
    [{
      prefix = "load-balancer"
      ip = data.netaddr_address_ipv4.postgres_lb.0.address
    }, {
      prefix = ""
      ip = data.netaddr_address_ipv4.postgres_lb.0.address
    }]
  )
}