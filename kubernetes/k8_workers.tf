resource "libvirt_volume" "kubernetes_worker_1" {
  name             = "ferlab-kubernetes-worker-1"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-focal-2022-12-13"
  format = "qcow2"
}

resource "libvirt_volume" "kubernetes_worker_2" {
  name             = "ferlab-kubernetes-worker-2"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-focal-2022-12-13"
  format = "qcow2"
}

resource "libvirt_volume" "kubernetes_worker_3" {
  name             = "ferlab-kubernetes-worker-3"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-focal-2022-12-13"
  format = "qcow2"
}

module "kubernetes_worker_1" {
  source = "./kvm-kubernetes-node"
  name = "ferlab-kubernetes-worker-1"
  vcpus = 8
  memory = 8192
  volume_id = libvirt_volume.kubernetes_worker_1.id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = data.netaddr_address_ipv4.k8_workers.0.address
    mac = data.netaddr_address_mac.k8_workers.0.address
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
}

module "kubernetes_worker_2" {
  source = "./kvm-kubernetes-node"
  name = "ferlab-kubernetes-worker-2"
  vcpus = 8
  memory = 8192
  volume_id = libvirt_volume.kubernetes_worker_2.id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = data.netaddr_address_ipv4.k8_workers.1.address
    mac = data.netaddr_address_mac.k8_workers.1.address
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
}

module "kubernetes_worker_3" {
  source = "./kvm-kubernetes-node"
  name = "ferlab-kubernetes-worker-3"
  vcpus = 8
  memory = 8192
  volume_id = libvirt_volume.kubernetes_worker_3.id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = data.netaddr_address_ipv4.k8_workers.2.address
    mac = data.netaddr_address_mac.k8_workers.2.address
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
}