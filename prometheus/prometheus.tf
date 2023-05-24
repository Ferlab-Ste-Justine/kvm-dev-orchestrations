resource "libvirt_volume" "prometheus" {
  name             = "ferlab-prometheus"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format           = "qcow2"
}

module "prometheus" {
  source = "./kvm-prometheus"
  name = "ferlab-prometheus-1"
  vcpus = local.params.prometheus.vcpus
  memory = local.params.prometheus.memory
  volume_id = libvirt_volume.prometheus.id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = data.netaddr_address_ipv4.prometheus.0.address
    mac = data.netaddr_address_mac.prometheus.0.address
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password

  etcd = {
    key_prefix = "/ferlab/prometheus/"
    endpoints = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
    ca_certificate = file("${path.module}/../shared/etcd-ca.pem")
    client = {
      certificate = ""
      key = ""
      username = "prometheus"
      password = random_password.prometheus_etcd_password.result
    }
  }

  prometheus = {
    web = {
      external_url = "http://prometheus.ferlab.lan:9090"
      max_connections = 512
      read_timeout = "5m"
    }
    retention = {
      time = "15d"
      size = "0"
    }
  }

  fluentbit = {
    enabled = local.params.logs_forwarding
    prometheus_tag = "prometheus-server-1-prometheus"
    prometheus_updater_tag = "prometheus-server-1-prometheus-updater"
    node_exporter_tag = "prometheus-server-1-node-exporter"
    metrics = {
      enabled = true
      port    = 2020
    }
    forward = {
      domain = local.host_params.ip
      port = 4443
      hostname = "prometheus-server-1"
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

  install_dependencies = true
}