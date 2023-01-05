resource "libvirt_volume" "kubernetes_master_1" {
  name             = "ferlab-kubernetes-master-1"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-focal-2022-12-13"
  format = "qcow2"
}

resource "libvirt_volume" "kubernetes_master_2" {
  name             = "ferlab-kubernetes-master-2"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-focal-2022-12-13"
  format = "qcow2"
}

resource "libvirt_volume" "kubernetes_master_3" {
  name             = "ferlab-kubernetes-master-3"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-focal-2022-12-13"
  format = "qcow2"
}

module "kubernetes_master_1" {
  source = "./kvm-kubernetes-node"
  name = "ferlab-kubernetes-master-1"
  vcpus = 1
  memory = 4096
  volume_id = libvirt_volume.kubernetes_master_1.id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = data.netaddr_address_ipv4.k8_masters.0.address
    mac = data.netaddr_address_mac.k8_masters.0.address
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
}

module "kubernetes_master_2" {
  source = "./kvm-kubernetes-node"
  name = "ferlab-kubernetes-master-2"
  vcpus = 1
  memory = 4096
  volume_id = libvirt_volume.kubernetes_master_2.id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = data.netaddr_address_ipv4.k8_masters.1.address
    mac = data.netaddr_address_mac.k8_masters.1.address
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
}

module "kubernetes_master_3" {
  source = "./kvm-kubernetes-node"
  name = "ferlab-kubernetes-master-3"
  vcpus = 1
  memory = 4096
  volume_id = libvirt_volume.kubernetes_master_3.id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = data.netaddr_address_ipv4.k8_masters.2.address
    mac = data.netaddr_address_mac.k8_masters.2.address
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
}