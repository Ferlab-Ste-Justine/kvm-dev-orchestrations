resource "libvirt_volume" "kubernetes_workers" {
  count            = local.params.k8_workers_count
  name             = "ferlab-kubernetes-worker-${count.index + 1}"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-focal-2022-12-13"
  format = "qcow2"
}

module "kubernetes_workers" {
  count  = local.params.k8_workers_count
  source = "./kvm-kubernetes-node"
  name = "ferlab-kubernetes-worker-${count.index + 1}"
  vcpus = 8
  memory = local.params.k8_workers_memory
  volume_id = libvirt_volume.kubernetes_workers[count.index].id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = element(data.netaddr_address_ipv4.k8_workers.*.address, count.index)
    mac = element(data.netaddr_address_mac.k8_workers.*.address, count.index)
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
}