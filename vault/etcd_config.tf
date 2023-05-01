provider "etcd" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert   = "${path.module}/../shared/etcd-ca.pem"
  username  = "root"
  password  = file("${path.module}/../shared/etcd-root_password")
}

data "etcd_prefix_range_end" "vault" {
  key = "/ferlab/vault/"
}

resource "etcd_role" "vault" {
  name = "vault"

  permissions {
    permission = "readwrite"
    key        = data.etcd_prefix_range_end.vault.key
    range_end  = data.etcd_prefix_range_end.vault.range_end
  }
}

resource "random_password" "vault_etcd_password" {
  length  = 16
  special = false
}

resource "etcd_user" "vault" {
  username = "vault"
  password = random_password.vault_etcd_password.result
  roles    = [etcd_role.vault.name]
}