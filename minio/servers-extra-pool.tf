resource "libvirt_volume" "minio_5" {
  count            = local.params.minio.extra_server_pool && local.params.minio.cluster_on ? 1 : 0
  name             = "ferlab-minio-5"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-05-18"
  format = "qcow2"
}

module "minio_5" {
  count = local.params.minio.extra_server_pool && local.params.minio.cluster_on ? 1 : 0
  source = "./terraform-libvirt-minio-server"
  name = "ferlab-minio-5"
  vcpus = local.params.etcd.vcpus
  memory = local.params.etcd.memory
  volume_id = libvirt_volume.minio_5.0.id
  data_disks = [
    {
      volume_id    = libvirt_volume.minio_5_1_data.0.id
      block_device = ""
      device_name  = "vdb"
      mount_label  = "minio_vol_a"
      mount_path   = "/opt/mnt/volume1"
    },
    {
      volume_id    = libvirt_volume.minio_5_2_data.0.id
      block_device = ""
      device_name  = "vdc"
      mount_label  = "minio_vol_b"
      mount_path   = "/opt/mnt/volume2"
    }
  ]
  ferio = local.ferio
  server_pools = local.static_server_pools
  minio_servers = element(local.minio_servers, local.params.minio.tenants)
  sse = local.sse
  prometheus_auth_type = local.prometheus_auth_type
  godebug_settings = local.godebug_settings
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = netaddr_address_ipv4.minio.4.address
    mac = netaddr_address_mac.minio.4.address
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  fluentbit = {
    enabled = local.params.logs_forwarding
    minio_tag = "minio-server-5-minio"
    kes_tag = "minio-server-5-kes"
    ferio_tag = "minio-server-5-ferio"
    node_exporter_tag = "minio-server-5-node-exporter"
    metrics = {
      enabled = true
      port    = 2020
    }
    forward = {
      domain = local.host_params.ip
      port = 4443
      hostname = "minio-server-5"
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

resource "libvirt_volume" "minio_6" {
  count            = local.params.minio.extra_server_pool && local.params.minio.cluster_on ? 1 : 0
  name             = "ferlab-minio-6"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-05-18"
  format = "qcow2"
}

module "minio_6" {
  count = local.params.minio.extra_server_pool && local.params.minio.cluster_on ? 1 : 0
  source = "./terraform-libvirt-minio-server"
  name = "ferlab-minio-6"
  vcpus = local.params.etcd.vcpus
  memory = local.params.etcd.memory
  volume_id = libvirt_volume.minio_6.0.id
  data_disks = [
    {
      volume_id    = libvirt_volume.minio_6_1_data.0.id
      block_device = ""
      device_name  = "vdb"
      mount_label  = "minio_vol_a"
      mount_path   = "/opt/mnt/volume1"
    },
    {
      volume_id    = libvirt_volume.minio_6_2_data.0.id
      block_device = ""
      device_name  = "vdc"
      mount_label  = "minio_vol_b"
      mount_path   = "/opt/mnt/volume2"
    }
  ]
  ferio = local.ferio
  server_pools = local.static_server_pools
  minio_servers = element(local.minio_servers, local.params.minio.tenants)
  sse = local.sse
  prometheus_auth_type = local.prometheus_auth_type
  godebug_settings = local.godebug_settings
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = netaddr_address_ipv4.minio.5.address
    mac = netaddr_address_mac.minio.5.address
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  fluentbit = {
    enabled = local.params.logs_forwarding
    minio_tag = "minio-server-6-minio"
    kes_tag = "minio-server-6-kes"
    ferio_tag = "minio-server-6-ferio"
    node_exporter_tag = "minio-server-6-node-exporter"
    metrics = {
      enabled = true
      port    = 2020
    }
    forward = {
      domain = local.host_params.ip
      port = 4443
      hostname = "minio-server-6"
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

resource "libvirt_volume" "minio_7" {
  count            = local.params.minio.extra_server_pool && local.params.minio.cluster_on ? 1 : 0
  name             = "ferlab-minio-7"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-05-18"
  format = "qcow2"
}

module "minio_7" {
  count = local.params.minio.extra_server_pool && local.params.minio.cluster_on ? 1 : 0
  source = "./terraform-libvirt-minio-server"
  name = "ferlab-minio-7"
  vcpus = local.params.etcd.vcpus
  memory = local.params.etcd.memory
  volume_id = libvirt_volume.minio_7.0.id
  data_disks = [
    {
      volume_id    = libvirt_volume.minio_7_1_data.0.id
      block_device = ""
      device_name  = "vdb"
      mount_label  = "minio_vol_a"
      mount_path   = "/opt/mnt/volume1"
    },
    {
      volume_id    = libvirt_volume.minio_7_2_data.0.id
      block_device = ""
      device_name  = "vdc"
      mount_label  = "minio_vol_b"
      mount_path   = "/opt/mnt/volume2"
    }
  ]
  ferio = local.ferio
  server_pools = local.static_server_pools
  minio_servers = element(local.minio_servers, local.params.minio.tenants)
  sse = local.sse
  prometheus_auth_type = local.prometheus_auth_type
  godebug_settings = local.godebug_settings
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = netaddr_address_ipv4.minio.6.address
    mac = netaddr_address_mac.minio.6.address
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  fluentbit = {
    enabled = local.params.logs_forwarding
    minio_tag = "minio-server-7-minio"
    kes_tag = "minio-server-7-kes"
    ferio_tag = "minio-server-7-ferio"
    node_exporter_tag = "minio-server-7-node-exporter"
    metrics = {
      enabled = true
      port    = 2020
    }
    forward = {
      domain = local.host_params.ip
      port = 4443
      hostname = "minio-server-7"
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

resource "libvirt_volume" "minio_8" {
  count            = local.params.minio.extra_server_pool && local.params.minio.cluster_on ? 1 : 0
  name             = "ferlab-minio-8"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-05-18"
  format = "qcow2"
}

module "minio_8" {
  count = local.params.minio.extra_server_pool && local.params.minio.cluster_on ? 1 : 0
  source = "./terraform-libvirt-minio-server"
  name = "ferlab-minio-8"
  vcpus = local.params.etcd.vcpus
  memory = local.params.etcd.memory
  volume_id = libvirt_volume.minio_8.0.id
  data_disks = [
    {
      volume_id    = libvirt_volume.minio_8_1_data.0.id
      block_device = ""
      device_name  = "vdb"
      mount_label  = "minio_vol_a"
      mount_path   = "/opt/mnt/volume1"
    },
    {
      volume_id    = libvirt_volume.minio_8_2_data.0.id
      block_device = ""
      device_name  = "vdc"
      mount_label  = "minio_vol_b"
      mount_path   = "/opt/mnt/volume2"
    }
  ]
  ferio = local.ferio
  server_pools = local.static_server_pools
  minio_servers = element(local.minio_servers, local.params.minio.tenants)
  sse = local.sse
  prometheus_auth_type = local.prometheus_auth_type
  godebug_settings = local.godebug_settings
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = netaddr_address_ipv4.minio.7.address
    mac = netaddr_address_mac.minio.7.address
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  fluentbit = {
    enabled = local.params.logs_forwarding
    minio_tag = "minio-server-8-minio"
    kes_tag = "minio-server-8-kes"
    ferio_tag = "minio-server-8-ferio"
    node_exporter_tag = "minio-server-8-node-exporter"
    metrics = {
      enabled = true
      port    = 2020
    }
    forward = {
      domain = local.host_params.ip
      port = 4443
      hostname = "minio-server-8"
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