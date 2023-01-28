resource "libvirt_volume" "coredns_1" {
  name             = "ferlab-coredns-1"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-focal-2022-12-13"
  format = "qcow2"
}

module "coredns_1" {
  source = "./kvm-coredns-server"
  name = "ferlab-coredns-1"
  vcpus = local.params.coredns.vcpus
  memory = local.params.coredns.memory
  volume_id = libvirt_volume.coredns_1.id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = data.netaddr_address_ipv4.coredns.0.address
    mac = data.netaddr_address_mac.coredns.0.address
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  etcd = {
    key_prefix = "/ferlab/coredns/"
    endpoints = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
    ca_certificate = file("${path.module}/../shared/etcd-ca.pem")
    client = {
      certificate = ""
      key = ""
      username = "coredns"
      password = random_password.coredns_etcd_password.result
    }
  }
  dns = {
    zonefiles_reload_interval = "3s"
    load_balance_records = true
    alternate_dns_servers = ["8.8.8.8"]
  }
}