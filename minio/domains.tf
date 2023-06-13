provider "etcd" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert = "${path.module}/../shared/etcd-ca.pem"
  username = "root"
  password = file("${path.module}/../shared/etcd-root_password")
}

module "minio_domain" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-zonefile.git"
  domain = "minio.ferlab.lan"
  key_prefix = "/ferlab/coredns/"
  dns_server_name = "ns.ferlab.lan."
  a_records = concat(
    [for server in netaddr_address_ipv4.minio: {
      prefix = ""
      ip = server.address
    }],
    [for idx, server in netaddr_address_ipv4.minio: {
      prefix = "server${idx + 1}"
      ip = server.address
    }]
  )
}