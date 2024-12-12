provider "etcd" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert = "${path.module}/../shared/etcd-ca.pem"
  username = !local.params.etcd.cert_auth ? "root" : null
  password = !local.params.etcd.cert_auth ? file("${path.module}/../shared/etcd-root_password") : null
  cert     = local.params.etcd.cert_auth ? "${path.module}/../shared/etcd-root.crt" : null
  key      = local.params.etcd.cert_auth ? "${path.module}/../shared/etcd-root.key" : null
}

data "etcd_prefix_range_end" "coredns" {
  key = "/ferlab/coredns/"
}

resource "etcd_role" "coredns" {
  name = "coredns"

  permissions {
    permission = "readwrite"
    key = data.etcd_prefix_range_end.coredns.key
    range_end = data.etcd_prefix_range_end.coredns.range_end
  }
}

resource "random_password" "coredns_etcd_password" {
  length           = 16
  special          = false
}

resource "etcd_user" "coredns" {
  username = "coredns"
  password = !local.params.etcd.cert_auth ? random_password.coredns_etcd_password.result : null
  roles = [etcd_role.coredns.name]
}

module "coredns_cert" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-tls-client-certificate.git?ref=843bf71115fcc318575ed5fbdb8bcf31973324d4"
  username = "coredns"
  ca = {
    key = file("${path.module}/../shared/etcd-ca.key")
    key_algorithm = file("${path.module}/../shared/etcd-ca_key_algorithm")
    certificate = file("${path.module}/../shared/etcd-ca.pem")
  }
}