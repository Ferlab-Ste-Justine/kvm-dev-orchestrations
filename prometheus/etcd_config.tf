provider "etcd" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert = "${path.module}/../shared/etcd-ca.pem"
  username = !local.params.etcd.cert_auth ? "root" : null
  password = !local.params.etcd.cert_auth ? file("${path.module}/../shared/etcd-root_password") : null
  cert     = local.params.etcd.cert_auth ? "${path.module}/../shared/etcd-root.crt" : null
  key      = local.params.etcd.cert_auth ? "${path.module}/../shared/etcd-root.key" : null
}

data "etcd_prefix_range_end" "prometheus" {
  key = "/ferlab/prometheus/"
}

resource "etcd_role" "prometheus" {
  name = "prometheus"

  permissions {
    permission = "readwrite"
    key = data.etcd_prefix_range_end.prometheus.key
    range_end = data.etcd_prefix_range_end.prometheus.range_end
  }
}

resource "random_password" "prometheus_etcd_password" {
  length           = 16
  special          = false
}

resource "etcd_user" "prometheus" {
  username = "prometheus"
  password = !local.params.etcd.cert_auth ? random_password.prometheus_etcd_password.result : null
  roles = [etcd_role.prometheus.name]
}

module "prometheus_cert" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-tls-client-certificate.git?ref=843bf71115fcc318575ed5fbdb8bcf31973324d4"
  username = "prometheus"
  ca = {
    key = file("${path.module}/../shared/etcd-ca.key")
    key_algorithm = file("${path.module}/../shared/etcd-ca_key_algorithm")
    certificate = file("${path.module}/../shared/etcd-ca.pem")
  }
}