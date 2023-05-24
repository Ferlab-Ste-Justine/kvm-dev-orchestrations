resource "libvirt_volume" "vault_lb_1" {
  name             = "ferlab-vault-lb-1"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format           = "qcow2"
}

module "vault_lb_1" {
  source          = "./terraform-libvirt-vault-load-balancer"
  name            = "ferlab-vault-lb-1"
  vcpus           = local.params.vault.load_balancer.vcpus
  memory          = local.params.vault.load_balancer.memory
  volume_id       = libvirt_volume.vault_lb_1.id
  libvirt_network = {
    network_name      = "ferlab"
    network_id        = ""
    ip                = data.netaddr_address_ipv4.vault_lb.0.address
    mac               = data.netaddr_address_mac.vault_lb.0.address
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key   = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password    = local.params.virsh_console_password
  tls = {
    ca_certificate     = module.vault_ca.certificate
    client_certificate = tls_locally_signed_cert.vault_certificate.cert_pem
    client_key         = tls_private_key.vault_key.private_key_pem
    client_auth        = false
  }
  haproxy                = {
    vault_nodes_max_count    = local.params.vault.servers.count
    vault_nameserver_ips     = [data.netaddr_address_ipv4.coredns.0.address]
    vault_domain             = "servers.vault.ferlab.lan"
    timeouts = {
      connect    = "15s"
      check      = "15s"
      idle       = "60s"
    }
  }
}