provider "etcd" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert   = "${path.module}/../shared/etcd-ca.pem"
  username  = "root"
  password  = file("${path.module}/../shared/etcd-root_password")
}

data "etcd_prefix_range_end" "vault_tunnel" {
  count = local.params.vault.load_balancer.tunnel ? 1 : 0
  key   = "/ferlab/vault-tunnel/"
}

resource "etcd_role" "vault_tunnel" {
  count = local.params.vault.load_balancer.tunnel ? 1 : 0
  name  = "vault-tunnel"

  permissions {
    permission = "readwrite"
    key        = data.etcd_prefix_range_end.vault_tunnel.0.key
    range_end  = data.etcd_prefix_range_end.vault_tunnel.0.range_end
  }
}

resource "random_password" "vault_tunnel_etcd_password" {
  count   = local.params.vault.load_balancer.tunnel ? 1 : 0
  length  = 16
  special = false
}

resource "etcd_user" "vault_tunnel" {
  count    = local.params.vault.load_balancer.tunnel ? 1 : 0
  username = "vault_tunnel"
  password = random_password.vault_tunnel_etcd_password.0.result
  roles    = [etcd_role.vault_tunnel.0.name]
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