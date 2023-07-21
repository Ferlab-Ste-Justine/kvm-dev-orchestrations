resource "libvirt_volume" "alertmanager" {
  count            = 2
  name             = "ferlab-alertmanager-${count.index + 1}"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format           = "qcow2"
}

module "alertmanager" {
  count = 2
  source = "./terraform-libvirt-alertmanager-server"
  name = "ferlab-alertmanager-${count.index + 1}"
  vcpus = local.params.alertmanager.vcpus
  memory = local.params.alertmanager.memory
  volume_id = libvirt_volume.alertmanager[count.index].id
  data_volume_id = local.params.alertmanager.data_volumes ? libvirt_volume.alertmanager_data[count.index].id: ""
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = netaddr_address_ipv4.alertmanager[count.index].address
    mac = netaddr_address_mac.alertmanager[count.index].address
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password

  etcd = {
    key_prefix = "/ferlab/alertmanager/"
    endpoints = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
    ca_certificate = file("${path.module}/../shared/etcd-ca.pem")
    client = {
      certificate = ""
      key = ""
      username = "alertmanager"
      password = random_password.alertmanager_etcd_password.result
    }
  }

  alertmanager = {
    external_url = "http://server-${count.index + 1}.alertmanager.ferlab.lan:9094"
    data_retention = "120h"
    peers = [for alertmanager in netaddr_address_ipv4.alertmanager: alertmanager.address]
    tls = {
      ca_cert     = module.alertmanager_ca.certificate
      server_cert = tls_locally_signed_cert.alertmanager.cert_pem
      server_key  = tls_private_key.alertmanager.private_key_pem
    }
    basic_auth = {
      username        = local.params.alertmanager.client_auth == "password" ? "alertmanager" : ""
      hashed_password = random_password.alertmanager_password.result
    }
  }

  fluentbit = {
    enabled = local.params.logs_forwarding
    alertmanager_tag         = "alertmanager-server-${count.index + 1}-alertmanager"
    alertmanager_updater_tag = "alertmanager-server-${count.index + 1}-alertmanager-updater"
    node_exporter_tag        = "alertmanager-server-${count.index + 1}-node-exporter"
    metrics = {
      enabled = true
      port    = 2020
    }
    forward = {
      domain = local.host_params.ip
      port = 4443
      hostname = "alertmanager-${count.index + 1}"
      shared_key = local.params.logs_forwarding ? file("${path.module}/../shared/logs_shared_key") : ""
      ca_cert = local.params.logs_forwarding ? file("${path.module}/../shared/logs_ca.crt") : ""
    }
  }

  receiver_secrets = [
    {
      path = "/opt/alertmanager-secrets/slack_webhook"
      content = file("${path.module}/../shared/slack_webhook")
    }
  ]

  install_dependencies = true
}