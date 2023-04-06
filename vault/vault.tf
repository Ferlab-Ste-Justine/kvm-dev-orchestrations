resource "libvirt_volume" "vault" {
  count            = local.params.vault.servers.count
  name             = "ferlab-vault-${count.index + 1}"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format           = "qcow2"
}

module "vault" {
  count           = local.params.vault.servers.count
  source          = "./terraform-libvirt-vault-server"
  name            = "ferlab-vault-${count.index + 1}"
  vcpus           = local.params.vault.servers.vcpus
  memory          = local.params.vault.servers.memory
  volume_id       = libvirt_volume.vault[count.index].id
  libvirt_network = {
    network_name      = "ferlab"
    network_id        = ""
    ip                = element(data.netaddr_address_ipv4.vault_servers.*.address, count.index)
    mac               = element(data.netaddr_address_mac.vault_servers.*.address, count.index)
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key   = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password    = local.params.virsh_console_password
  tls = {
    ca_certificate     = module.vault_ca.certificate
    server_certificate = tls_locally_signed_cert.vault_certificate.cert_pem
    server_key         = tls_private_key.vault_key.private_key_pem
    client_auth        = false
  }
  etcd_backend = {
    key_prefix     = "/ferlab/vault/"
    urls           = join(",", [for etcd in local.params.etcd.addresses: "https://${etcd.ip}:2379"])
    ca_certificate = file("${path.module}/../shared/etcd-ca.pem")
    client         = {
      certificate      = ""
      key              = ""
      username         = "vault"
      password         = random_password.vault_etcd_password.result
    }
  }
}
