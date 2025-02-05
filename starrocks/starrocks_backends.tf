resource "libvirt_volume" "be_nodes" {
  count            = local.params.starrocks.be_nodes.count
  name             = "ferlab-starrocks-be-${count.index + 1}"
  pool             = "default"
  size             = 30 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2024-03-01"
  format           = "qcow2"
}

module "be_nodes" {
  count            = local.params.starrocks.be_nodes.count
  source           = "./terraform-libvirt-starrocks-server"
  name             = "ferlab-starrocks-be-${count.index + 1}"
  vcpus            = local.params.starrocks.be_nodes.vcpus
  memory           = local.params.starrocks.be_nodes.memory
  volume_id        = libvirt_volume.be_nodes[count.index].id
  libvirt_networks = [{
    network_name  = "ferlab"
    network_id    = ""
    ip            = element(netaddr_address_ipv4.be_nodes.*.address, count.index)
    mac           = element(netaddr_address_mac.be_nodes.*.address, count.index)
    gateway       = local.params.network.gateway
    dns_servers   = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key   = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password    = local.params.virsh_console_password
  starrocks              = {
    release_version   = "3.3.6"
    node_type         = "be"
    is_fe_leader      = false
    fe_leader_node    = local.fe_leader_node
    fe_follower_nodes = local.fe_follower_nodes
    be_nodes          = local.be_nodes
    root_password     = local.params.starrocks.root_password
  }
}
