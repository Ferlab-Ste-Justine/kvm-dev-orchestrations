resource "libvirt_volume" "custom" {
  name             = "ferlab-custom"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2024-03-01"
  format           = "qcow2"
}

module "custom" {
  source           = "./terraform-libvirt-custom-server"
  name             = "ferlab-custom"
  vcpus            = local.params.custom.vcpus
  memory           = local.params.custom.memory
  volume_ids       = [libvirt_volume.custom.id]
  libvirt_networks = [{
    network_name        = "ferlab"
    network_id          = ""
    ip                  = netaddr_address_ipv4.custom.address
    mac                 = netaddr_address_mac.custom.address
    gateway             = local.params.network.gateway
    dns_servers         = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length       = split("/", local.params.network.addresses).1
  }]
  cloud_init_configurations = [
    {
      filename = "custom.cfg"
      content = file("user_data.yml")
    }
  ]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key   = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password    = local.params.virsh_console_password
}
