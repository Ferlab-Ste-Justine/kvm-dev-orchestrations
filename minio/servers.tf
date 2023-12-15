locals {
  sse = {
    enabled = fileexists("${path.module}/../shared/minio-kes-approle-id")
    server = {
      tls          = {
        client_cert = tls_locally_signed_cert.minio.cert_pem
        client_key  = tls_private_key.minio.private_key_pem
        server_cert = tls_locally_signed_cert.minio.cert_pem
        server_key  = tls_private_key.minio.private_key_pem
        ca_cert     = module.minio_ca.certificate
      }
      cache_expiry = "1m"
      audit_logs   = true
    }
    vault          = {
      endpoint       = "vault.ferlab.lan"
      mount          = "minio-kes"
      kv_version     = "v2"
      prefix         = ""
      approle        = {
        mount          = "minio-kes"
        id             = fileexists("${path.module}/../shared/minio-kes-approle-id") ? file("${path.module}/../shared/minio-kes-approle-id") : ""
        secret         = fileexists("${path.module}/../shared/minio-kes-approle-secret") ? file("${path.module}/../shared/minio-kes-approle-secret") : ""
        retry_interval = "10s"
      }
      ca_cert        = fileexists("${path.module}/../shared/vault-ca.crt") ? file("${path.module}/../shared/vault-ca.crt") : ""
      ping_interval  = "10s"
    }
  }
}

resource "libvirt_volume" "minio_1" {
  name             = "ferlab-minio-1"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format = "qcow2"
}

module "minio_1" {
  source = "./terraform-libvirt-minio-server"
  name = "ferlab-minio-1"
  vcpus = local.params.etcd.vcpus
  memory = local.params.etcd.memory
  volume_id = libvirt_volume.minio_1.id
  data_disks = [
    {
      volume_id    = libvirt_volume.minio_1_1_data.id
      block_device = ""
      device_name  = "vdb"
      mount_label  = "minio_vol_a"
      mount_path   = "/opt/mnt/volume1"
    },
    {
      volume_id    = libvirt_volume.minio_1_2_data.id
      block_device = ""
      device_name  = "vdc"
      mount_label  = "minio_vol_b"
      mount_path   = "/opt/mnt/volume2"
    }
  ]
  server_pools = [{
    domain_template     = "server%s.minio.ferlab.lan"
    servers_count_begin = 1
    servers_count_end   = 4
    mount_path_template = "/opt/mnt/volume%s"
    mounts_count        = 2
  }]
  minio_server = {
    tls = {
      server_cert = tls_locally_signed_cert.minio.cert_pem
      server_key  = tls_private_key.minio.private_key_pem
      ca_cert     = module.minio_ca.certificate
    }
    auth = {
      root_username = local.params.minio.root_username
      root_password = local.params.minio.root_password
    }
    load_balancer_url = "https://minio.ferlab.lan:9000"
  }
  sse = local.sse
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = netaddr_address_ipv4.minio.0.address
    mac = netaddr_address_mac.minio.0.address
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  fluentbit = {
    enabled = local.params.logs_forwarding
    minio_tag = "minio-server-1-minio"
    kes_tag = "minio-server-1-kes"
    node_exporter_tag = "minio-server-1-node-exporter"
    metrics = {
      enabled = true
      port    = 2020
    }
    forward = {
      domain = local.host_params.ip
      port = 4443
      hostname = "minio-server-1"
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

resource "libvirt_volume" "minio_2" {
  name             = "ferlab-minio-2"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format = "qcow2"
}

module "minio_2" {
  source = "./terraform-libvirt-minio-server"
  name = "ferlab-minio-2"
  vcpus = local.params.etcd.vcpus
  memory = local.params.etcd.memory
  volume_id = libvirt_volume.minio_2.id
  data_disks = [
    {
      volume_id    = libvirt_volume.minio_2_1_data.id
      block_device = ""
      device_name  = "vdb"
      mount_label  = "minio_vol_a"
      mount_path   = "/opt/mnt/volume1"
    },
    {
      volume_id    = libvirt_volume.minio_2_2_data.id
      block_device = ""
      device_name  = "vdc"
      mount_label  = "minio_vol_b"
      mount_path   = "/opt/mnt/volume2"
    }
  ]
  server_pools = [{
    domain_template     = "server%s.minio.ferlab.lan"
    servers_count_begin = 1
    servers_count_end   = 4
    mount_path_template = "/opt/mnt/volume%s"
    mounts_count        = 2
  }]
  minio_server = {
    tls = {
      server_cert = tls_locally_signed_cert.minio.cert_pem
      server_key  = tls_private_key.minio.private_key_pem
      ca_cert     = module.minio_ca.certificate
    }
    auth = {
      root_username = local.params.minio.root_username
      root_password = local.params.minio.root_password
    }
    load_balancer_url = "https://minio.ferlab.lan:9000"
  }
  sse = local.sse
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = netaddr_address_ipv4.minio.1.address
    mac = netaddr_address_mac.minio.1.address
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  fluentbit = {
    enabled = local.params.logs_forwarding
    minio_tag = "minio-server-2-minio"
    kes_tag = "minio-server-2-kes"
    node_exporter_tag = "minio-server-2-node-exporter"
    metrics = {
      enabled = true
      port    = 2020
    }
    forward = {
      domain = local.host_params.ip
      port = 4443
      hostname = "minio-server-2"
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

resource "libvirt_volume" "minio_3" {
  name             = "ferlab-minio-3"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format = "qcow2"
}

module "minio_3" {
  source = "./terraform-libvirt-minio-server"
  name = "ferlab-minio-3"
  vcpus = local.params.etcd.vcpus
  memory = local.params.etcd.memory
  volume_id = libvirt_volume.minio_3.id
  data_disks = [
    {
      volume_id    = libvirt_volume.minio_3_1_data.id
      block_device = ""
      device_name  = "vdb"
      mount_label  = "minio_vol_a"
      mount_path   = "/opt/mnt/volume1"
    },
    {
      volume_id    = libvirt_volume.minio_3_2_data.id
      block_device = ""
      device_name  = "vdc"
      mount_label  = "minio_vol_b"
      mount_path   = "/opt/mnt/volume2"
    }
  ]
  server_pools = [{
    domain_template     = "server%s.minio.ferlab.lan"
    servers_count_begin = 1
    servers_count_end   = 4
    mount_path_template = "/opt/mnt/volume%s"
    mounts_count        = 2
  }]
  minio_server = {
    tls = {
      server_cert = tls_locally_signed_cert.minio.cert_pem
      server_key  = tls_private_key.minio.private_key_pem
      ca_cert     = module.minio_ca.certificate
    }
    auth = {
      root_username = local.params.minio.root_username
      root_password = local.params.minio.root_password
    }
    load_balancer_url = "https://minio.ferlab.lan:9000"
  }
  sse = local.sse
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = netaddr_address_ipv4.minio.2.address
    mac = netaddr_address_mac.minio.2.address
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  fluentbit = {
    enabled = local.params.logs_forwarding
    minio_tag = "minio-server-3-minio"
    kes_tag = "minio-server-3-kes"
    node_exporter_tag = "minio-server-3-node-exporter"
    metrics = {
      enabled = true
      port    = 2020
    }
    forward = {
      domain = local.host_params.ip
      port = 4443
      hostname = "minio-server-3"
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

resource "libvirt_volume" "minio_4" {
  name             = "ferlab-minio-4"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format = "qcow2"
}

module "minio_4" {
  source = "./terraform-libvirt-minio-server"
  name = "ferlab-minio-4"
  vcpus = local.params.etcd.vcpus
  memory = local.params.etcd.memory
  volume_id = libvirt_volume.minio_4.id
  data_disks = [
    {
      volume_id    = libvirt_volume.minio_4_1_data.id
      block_device = ""
      device_name  = "vdb"
      mount_label  = "minio_vol_a"
      mount_path   = "/opt/mnt/volume1"
    },
    {
      volume_id    = libvirt_volume.minio_4_2_data.id
      block_device = ""
      device_name  = "vdc"
      mount_label  = "minio_vol_b"
      mount_path   = "/opt/mnt/volume2"
    }
  ]
  server_pools = [{
    domain_template     = "server%s.minio.ferlab.lan"
    servers_count_begin = 1
    servers_count_end   = 4
    mount_path_template = "/opt/mnt/volume%s"
    mounts_count        = 2
  }]
  minio_server = {
    tls = {
      server_cert = tls_locally_signed_cert.minio.cert_pem
      server_key  = tls_private_key.minio.private_key_pem
      ca_cert     = module.minio_ca.certificate
    }
    auth = {
      root_username = local.params.minio.root_username
      root_password = local.params.minio.root_password
    }
    load_balancer_url = "https://minio.ferlab.lan:9000"
  }
  sse = local.sse
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = netaddr_address_ipv4.minio.3.address
    mac = netaddr_address_mac.minio.3.address
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  fluentbit = {
    enabled = local.params.logs_forwarding
    minio_tag = "minio-server-4-minio"
    kes_tag = "minio-server-4-kes"
    node_exporter_tag = "minio-server-4-node-exporter"
    metrics = {
      enabled = true
      port    = 2020
    }
    forward = {
      domain = local.host_params.ip
      port = 4443
      hostname = "minio-server-4"
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