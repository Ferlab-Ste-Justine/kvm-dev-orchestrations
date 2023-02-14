resource "libvirt_volume" "bastion" {
  name             = "ferlab-k8-bastion"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format = "qcow2"
}

module "bastion" {
  source = "./kvm-bastion"
  name = "ferlab-k8-bastion"
  vcpus = local.params.kubernetes.bastion.vcpus
  memory = local.params.kubernetes.bastion.memory
  volume_id = libvirt_volume.bastion.id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = data.netaddr_address_ipv4.k8_bastion.0.address
    mac = data.netaddr_address_mac.k8_bastion.0.address
  }
  cloud_init_volume_pool = "default"
  admin_user_password = local.params.virsh_console_password
  ssh_internal_public_key = tls_private_key.admin_ssh.public_key_openssh
  ssh_internal_private_key = tls_private_key.admin_ssh.private_key_openssh
  ssh_external_public_key = tls_private_key.admin_ssh.public_key_openssh
}