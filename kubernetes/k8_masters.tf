resource "libvirt_volume" "kubernetes_masters" {
  count            = local.params.k8_masters_count
  name             = "ferlab-kubernetes-master-${count.index + 1}"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-focal-2022-12-13"
  format = "qcow2"
}

module "kubernetes_masters" {
  count  = local.params.k8_masters_count
  source = "./kvm-kubernetes-node"
  name = "ferlab-kubernetes-master-${count.index + 1}"
  vcpus = local.params.k8_masters_vcpus
  memory = local.params.k8_masters_memory
  volume_id = libvirt_volume.kubernetes_masters[count.index].id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = element(data.netaddr_address_ipv4.k8_masters.*.address, count.index)
    mac = element(data.netaddr_address_mac.k8_masters.*.address, count.index)
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
}