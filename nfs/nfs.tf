resource "libvirt_volume" "nfs" {
  name             = "ferlab-nfs"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-focal-2022-12-13"
  format           = "qcow2"
}

module "nfs" {
  source = "./terraform-libvirt-nfs-server"
  name = "ferlab-nfs"
  vcpus = local.params.nfs.vcpus
  memory = local.params.nfs.memory
  volume_id = libvirt_volume.nfs.id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = data.netaddr_address_ipv4.nfs.address
    mac = data.netaddr_address_mac.nfs.address
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  nfs_configs = [
    {
      path = "/opt/fs"
      rw = true
      sync = true
      subtree_check = false
      no_root_squash = true
    }
  ]
  nfs_tunnel = {
    listening_port     = 2050
    server_key         = tls_private_key.nfs_tunnel_server_key.private_key_pem
    server_certificate = tls_locally_signed_cert.nfs_tunnel_server_certificate.cert_pem
    ca_certificate     = module.nfs_ca.certificate
    max_connections    = 1000
    idle_timeout       = "600s"
  }
}