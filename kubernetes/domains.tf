provider "etcd" {
  endpoints = join(",", [for etcd in local.params.etcd_addresses: "${etcd.ip}:2379"])
  ca_cert = "${path.module}/../shared/etcd-ca.pem"
  username = "root"
  password = file("${path.module}/../shared/etcd-root_password")
}

module "kubernetes_domain" {
  source = "git::https://github.com/Ferlab-Ste-Justine/etcd-zonefile.git"
  domain = "k8.ferlab.local"
  key_prefix = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.local."
  a_records = concat(
    [for lb in data.netaddr_address_ipv4.k8_lb: {
      prefix = ""
      ip = lb.address
    }],
    [for master in data.netaddr_address_ipv4.k8_masters: {
      prefix = "masters"
      ip = master.address
    }],
    [for worker in data.netaddr_address_ipv4.k8_workers: {
      prefix = "workers"
      ip = worker.address
    }],
  )
}