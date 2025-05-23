locals {
  alertmanager_secrets = fileexists("${path.module}/../shared/alertmanager_ca.crt") ? [
    {
      path = "/opt/alertmanager/ca.crt",
      content = file("${path.module}/../shared/alertmanager_ca.crt")
    },
    {
      path = "/opt/alertmanager/client.crt",
      content = file("${path.module}/../shared/alertmanager_client.crt")
    },
    {
      path = "/opt/alertmanager/client.key",
      content = file("${path.module}/../shared/alertmanager_client.key")
    },
    {
      path = "/opt/alertmanager/password",
      content = file("${path.module}/../shared/alertmanager_password")
    }
  ] : []
  automation_server_secrets = fileexists("${path.module}/../shared/automation_server_pushgateway_ca.crt") ? [
    {
      path = "/opt/automation-server-pushgateway/ca.crt",
      content = file("${path.module}/../shared/automation_server_pushgateway_ca.crt")
    },
    {
      path = "/opt/automation-server-pushgateway/client.crt",
      content = file("${path.module}/../shared/automation_server_pushgateway.crt")
    },
    {
      path = "/opt/automation-server-pushgateway/client.key",
      content = file("${path.module}/../shared/automation_server_pushgateway.key")
    }
  ] : []
  minio_secrets = fileexists("${path.module}/../shared/minio_ca.crt") ? [
    {
      path = "/opt/minio/ca.crt",
      content = file("${path.module}/../shared/minio_ca.crt")
    }
  ] : []
  etcd_secrets = fileexists("${path.module}/../shared/etcd-ca.pem") ? [
    {
      path = "/opt/etcd/ca.crt",
      content = file("${path.module}/../shared/etcd-ca.pem")
    }
  ] : []
  patroni_secrets = fileexists("${path.module}/../shared/postgres_ca.crt") ? [
    {
      path = "/opt/patroni/ca.crt",
      content = file("${path.module}/../shared/postgres_ca.crt")
    },
    {
      path = "/opt/patroni/client.crt",
      content = file("${path.module}/../shared/patroni_client.crt")
    },
    {
      path = "/opt/patroni/client.key",
      content = file("${path.module}/../shared/patroni_client.key")
    }
  ] : []
  pushgateway_secrets = fileexists("${path.module}/../terracd/pushgateway/certs/local_ca.crt") ? [
    {
      path = "/opt/physical-host-pushgateway/ca.crt",
      content = file("${path.module}/../terracd/pushgateway/certs/local_ca.crt")
    },
    {
      path = "/opt/physical-host-pushgateway/client.crt",
      content = file("${path.module}/../terracd/pushgateway/certs/local_client.crt")
    },
    {
      path = "/opt/physical-host-pushgateway/client.key",
      content = file("${path.module}/../terracd/pushgateway/certs/local_client.key")
    }
  ] : []
}

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
  data_volume_id = local.params.prometheus.data_volumes ? libvirt_volume.prometheus_1_data.0.id : ""
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = netaddr_address_ipv4.prometheus.0.address
    mac = netaddr_address_mac.prometheus.0.address
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password

  etcd = {
    key_prefix = "/ferlab/prometheus/"
    endpoints = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
    ca_certificate = file("${path.module}/../shared/etcd-ca.pem")
    client = {
      certificate = local.params.etcd.cert_auth ? module.prometheus_cert.certificate : ""
      key = local.params.etcd.cert_auth ? module.prometheus_cert.key : ""
      username = !local.params.etcd.cert_auth ? "prometheus" : ""
      password = !local.params.etcd.cert_auth ? random_password.prometheus_etcd_password.result : ""
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
  }

  prometheus_secrets = concat(
    local.alertmanager_secrets,
    local.automation_server_secrets,
    local.minio_secrets,
    local.etcd_secrets,
    local.patroni_secrets,
    local.pushgateway_secrets
  )

  install_dependencies = true
}