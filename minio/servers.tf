locals {
  sse_server_clients = [
    #No tenants
    [{
    tls = {
      client_cert = tls_locally_signed_cert.ferlab_tenant_client_sse.cert_pem
      client_key  = tls_private_key.minio.private_key_pem
    }
    key = "ferlab"
    }],
    #One tenant
    [{
    tls = {
      client_cert = tls_locally_signed_cert.ferlab_tenant_client_sse.cert_pem
      client_key  = tls_private_key.minio.private_key_pem
    }
    key = "ferlab"
    }],
    #Two tenants
    [
      {
        tls = {
          client_cert = tls_locally_signed_cert.ferlab_tenant_client_sse.cert_pem
          client_key  = tls_private_key.minio.private_key_pem
        }
        key = "ferlab"
      },
      {
        tls = {
          client_cert = tls_locally_signed_cert.ferlab2_tenant_client_sse.cert_pem
          client_key  = tls_private_key.ferlab2_tenant_client_sse.private_key_pem
        }
        key = "ferlab2"
      }
    ],
  ]
  sse = {
    enabled = fileexists("${path.module}/../shared/minio-kes-approle-id")
    server = {
      clients = element(local.sse_server_clients, local.params.minio.tenants)
      tls          = {
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
  static_server_pools = local.params.minio.extra_server_pool ? [
      {
        domain_template     = "server%s.minio.ferlab.lan"
        servers_count_begin  = 1
        servers_count_end    = 4
        mount_path_template = "/opt/mnt/volume%s"
        mounts_count         = 2
      },
      {
        domain_template     = "server%s.minio.ferlab.lan"
        servers_count_begin  = 5
        servers_count_end    = 8
        mount_path_template = "/opt/mnt/volume%s"
        mounts_count         = 2
      }
  ] : [{
    domain_template     = "server%s.minio.ferlab.lan"
    servers_count_begin = 1
    servers_count_end   = 4
    mount_path_template = "/opt/mnt/volume%s"
    mounts_count        = 2
  }]
  minio_servers = [
    #No tenants
    [{
      tenant_name = ""
      tls = {
        server_cert = tls_locally_signed_cert.minio.cert_pem
        server_key  = tls_private_key.minio.private_key_pem
        ca_certs     = [
          module.minio_ca.certificate,
          module.minio_ingress_ca.certificate
        ]
      }
      auth = {
        root_username = local.params.minio.root_username
        root_password = local.params.minio.root_password
      }
      api_url = local.params.minio.k8_ingress_setup ? "https://minio-api.k8.ferlab.lan" : "https://minio.ferlab.lan:9000"
      console_url = local.params.minio.k8_ingress_setup ? "https://minio-console.k8.ferlab.lan" : "https://minio.ferlab.lan:9001"
    }],
    #One tenant
    [{
      tenant_name = "ferlab"
      migrate_to = local.params.minio.migrate_to_tenants
      tls = {
        server_cert = tls_locally_signed_cert.minio.cert_pem
        server_key  = tls_private_key.minio.private_key_pem
        ca_certs     = [
          module.minio_ca.certificate,
          module.minio_ingress_ca.certificate
        ]
      }
      auth = {
        root_username = local.params.minio.root_username
        root_password = local.params.minio.root_password
      }
      api_url = local.params.minio.k8_ingress_setup ? "https://minio-api.k8.ferlab.lan" : "https://minio.ferlab.lan:9000"
      console_url = local.params.minio.k8_ingress_setup ? "https://minio-console.k8.ferlab.lan" : "https://minio.ferlab.lan:9001"
    }],
    #two tenant
    [
      {
        tenant_name = "ferlab"
        migrate_to = local.params.minio.migrate_to_tenants
        tls = {
          server_cert = tls_locally_signed_cert.minio.cert_pem
          server_key  = tls_private_key.minio.private_key_pem
          ca_certs     = [
            module.minio_ca.certificate,
            module.minio_ingress_ca.certificate
          ]
        }
        auth = {
          root_username = local.params.minio.root_username
          root_password = local.params.minio.root_password
        }
        api_url = local.params.minio.k8_ingress_setup ? "https://minio-api.k8.ferlab.lan" : "https://minio.ferlab.lan:9000"
        console_url = local.params.minio.k8_ingress_setup ? "https://minio-console.k8.ferlab.lan" : "https://minio.ferlab.lan:9001"
      },
      {
        tenant_name = "ferlab2"
        tls = {
          server_cert = tls_locally_signed_cert.minio.cert_pem
          server_key  = tls_private_key.minio.private_key_pem
          ca_certs     = [
            module.minio_ca.certificate,
            module.minio_ingress_ca.certificate
          ]
        }
        auth = {
          root_username = local.params.minio.root_username
          root_password = local.params.minio.root_password
        }
        api_port = 9002
        console_port = 9003
        api_url = "https://minio.ferlab.lan:9002"
        console_url = "https://minio.ferlab.lan:9003"
      }
    ]
  ]
  ferio = {
    enabled = local.params.minio.ferio_enabled
    etcd = {
      config_prefix      = "/ferlab/ferio/config/"
      workspace_prefix   = "/ferlab/ferio/workspace/"
      endpoints          = local.params.minio.ferio_enabled ? [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"] : []
      auth               = {
        ca_cert = file("${path.module}/../shared/etcd-ca.pem")
        username = "root"
        password = file("${path.module}/../shared/etcd-root_password")
        client_cert = ""
        client_key = ""
      }
    }
  }
  prometheus_auth_type = "public"
  godebug_settings     = "gcshrinkstackoff=1"  # to prevent crashes, see https://github.com/minio/minio/issues/18808#issuecomment-1895441463
}

resource "libvirt_volume" "minio_1" {
  count = local.params.minio.cluster_on ? 1 : 0
  name             = "ferlab-minio-1"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-05-18"
  format = "qcow2"
}

module "minio_1" {
  count = local.params.minio.cluster_on ? 1 : 0
  source = "./terraform-libvirt-minio-server"
  name = "ferlab-minio-1"
  vcpus = local.params.etcd.vcpus
  memory = local.params.etcd.memory
  volume_id = libvirt_volume.minio_1.0.id
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
  ferio = local.ferio
  server_pools = local.static_server_pools
  minio_servers = element(local.minio_servers, local.params.minio.tenants)
  sse = local.sse
  prometheus_auth_type = local.prometheus_auth_type
  godebug_settings = local.godebug_settings
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
    ferio_tag = "minio-server-1-ferio"
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
  count = local.params.minio.cluster_on ? 1 : 0
  name             = "ferlab-minio-2"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-05-18"
  format = "qcow2"
}

module "minio_2" {
  count = local.params.minio.cluster_on ? 1 : 0
  source = "./terraform-libvirt-minio-server"
  name = "ferlab-minio-2"
  vcpus = local.params.etcd.vcpus
  memory = local.params.etcd.memory
  volume_id = libvirt_volume.minio_2.0.id
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
  ferio = local.ferio
  server_pools = local.static_server_pools
  minio_servers = element(local.minio_servers, local.params.minio.tenants)
  sse = local.sse
  prometheus_auth_type = local.prometheus_auth_type
  godebug_settings = local.godebug_settings
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
    ferio_tag = "minio-server-2-ferio"
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
  count = local.params.minio.cluster_on ? 1 : 0
  name             = "ferlab-minio-3"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-05-18"
  format = "qcow2"
}

module "minio_3" {
  count = local.params.minio.cluster_on ? 1 : 0
  source = "./terraform-libvirt-minio-server"
  name = "ferlab-minio-3"
  vcpus = local.params.etcd.vcpus
  memory = local.params.etcd.memory
  volume_id = libvirt_volume.minio_3.0.id
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
  ferio = local.ferio
  server_pools = local.static_server_pools
  minio_servers = element(local.minio_servers, local.params.minio.tenants)
  sse = local.sse
  prometheus_auth_type = local.prometheus_auth_type
  godebug_settings = local.godebug_settings
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
    ferio_tag = "minio-server-3-ferio"
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
  count = local.params.minio.cluster_on ? 1 : 0
  name             = "ferlab-minio-4"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-05-18"
  format = "qcow2"
}

module "minio_4" {
  count = local.params.minio.cluster_on ? 1 : 0
  source = "./terraform-libvirt-minio-server"
  name = "ferlab-minio-4"
  vcpus = local.params.etcd.vcpus
  memory = local.params.etcd.memory
  volume_id = libvirt_volume.minio_4.0.id
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
  ferio = local.ferio
  server_pools = local.static_server_pools
  minio_servers = element(local.minio_servers, local.params.minio.tenants)
  sse = local.sse
  prometheus_auth_type = local.prometheus_auth_type
  godebug_settings = local.godebug_settings
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
    ferio_tag = "minio-server-4-ferio"
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