resource "libvirt_volume" "nfs" {
  name             = "ferlab-nfs"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format           = "qcow2"
}

module "nfs" {
  source = "./terraform-libvirt-nfs-server"
  name = "ferlab-nfs"
  vcpus = local.params.nfs.vcpus
  memory = local.params.nfs.memory
  volume_id = libvirt_volume.nfs.id
  data_volume = {
    id = local.params.nfs.data_volumes ? libvirt_volume.nfs_data.0.id : ""
    mount_path = "/opt/fs"
  }
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = netaddr_address_ipv4.nfs.address
    mac = netaddr_address_mac.nfs.address
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  nfs_configs = [
    {
      path = "/opt/fs"
      rw = true
      sync = true
      subtree_check = false
      no_root_squash = true
    }
  ]
  nfs_tunnel = {
    listening_port     = 2050
    server_key         = tls_private_key.nfs_tunnel_server_key.private_key_pem
    server_certificate = tls_locally_signed_cert.nfs_tunnel_server_certificate.cert_pem
    ca_certificate     = module.nfs_ca.certificate
    max_connections    = 1000
    idle_timeout       = "600s"
  }
  fluentbit = {
    enabled = local.params.logs_forwarding
    nfs_tunnel_server_tag = "nfs-server-tls-tunnel"
    s3_backup_tag = "nfs-server-s3-outgoing-sync"
    s3_restore_tag = "nfs-server-s3-incoming-sync"
    node_exporter_tag = "nfs-server-node-exporter"
    metrics = {
      enabled = true
      port    = 2020
    }
    forward = {
      domain = local.host_params.ip
      port = 4443
      hostname = "nfs-server"
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