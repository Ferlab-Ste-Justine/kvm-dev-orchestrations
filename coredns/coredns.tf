resource "libvirt_volume" "coredns_1" {
  name             = "ferlab-coredns-1"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format = "qcow2"
}

module "coredns_1" {
  source = "./kvm-coredns-server"
  name = "ferlab-coredns-1"
  vcpus = local.params.coredns.vcpus
  memory = local.params.coredns.memory
  volume_id = libvirt_volume.coredns_1.id
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = netaddr_address_ipv4.coredns.address
    mac = netaddr_address_mac.coredns.address
    gateway = local.params.network.gateway
    dns_servers = [local.params.network.dns]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  etcd = {
    key_prefix = "/ferlab/coredns/"
    endpoints = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
    ca_certificate = file("${path.module}/../shared/etcd-ca.pem")
    client = {
      certificate = local.params.etcd.cert_auth ? module.coredns_cert.certificate : ""
      key = local.params.etcd.cert_auth ? module.coredns_cert.key : ""
      username = !local.params.etcd.cert_auth ? "coredns" : ""
      password = !local.params.etcd.cert_auth ? random_password.coredns_etcd_password.result : ""
    }
  }
  dns = {
    zonefiles_reload_interval = "3s"
    load_balance_records = true
    alternate_dns_servers = [local.host_params.dns]
  }
  fluentbit = {
    enabled = local.params.logs_forwarding
    coredns_tag = "coredns-server-1-coredns"
    coredns_updater_tag = "coredns-server-1-coredns-updater"
    node_exporter_tag = "coredns-server-1-node-exporter"
    metrics = {
      enabled = true
      port    = 2020
    }
    forward = {
      domain = local.host_params.ip
      port = 4443
      hostname = "coredns-server-1"
      shared_key = local.params.logs_forwarding ? file("${path.module}/../shared/logs_shared_key") : ""
      ca_cert = local.params.logs_forwarding ? file("${path.module}/../shared/logs_ca.crt") : ""
    }
    etcd = {
      enabled = false
      key_prefix = ""
      endpoints = []
      ca_certificate = ""
      client = {
        certificate = ""
        key = ""
        username = ""
        password = ""
      }
    }
  }
}