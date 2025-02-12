resource "libvirt_volume" "smrtlink_data" {
  count            = local.params.smrtlink.data_volume ? 1 : 0
  name             = "ferlab-smrtlink-data"
  pool             = "default"
  size             = 30 * 1024 * 1024 * 1024
  format           = "qcow2"
}

resource "libvirt_volume" "smrtlink" {
  name             = "ferlab-smrtlink"
  pool             = "default"
  size             = 20 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2024-03-01"
  format           = "qcow2"
}

module "smrtlink" {
  source           = "./terraform-libvirt-smrtlink-server"
  name             = "ferlab-smrtlink"
  vcpus            = local.params.smrtlink.vcpus
  memory           = local.params.smrtlink.memory
  volume_id        = libvirt_volume.smrtlink.id
  data_volume_id   = local.params.smrtlink.data_volume ? libvirt_volume.smrtlink_data[0].id: ""
  libvirt_networks = [{
    network_name        = "ferlab"
    network_id          = ""
    ip                  = netaddr_address_ipv4.smrtlink.address
    mac                 = netaddr_address_mac.smrtlink.address
    gateway             = local.params.network.gateway
    dns_servers         = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length       = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key   = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password    = local.params.virsh_console_password
  smrtlink               = {
    domain_name = "smrtlink.ferlab.lan"
    keycloak_user_passwords = {
      admin     = local.params.smrtlink.admin_password
      pbicsuser = local.params.smrtlink.pbicsuser_password
    }
    db_backups = {
      enabled         = local.params.smrtlink.db_backups
      cron_expression = "*/10 * * * *"  # every 10 minutes
      retention_days  = 1
    }
  }
  s3_backups = {
    enabled                = local.params.smrtlink.s3_backups
    restore                = false
    url                    = "https://minio.ferlab.lan:9000"
    region                 = "us-east-1"
    access_key             = local.params.minio.root_username
    secret_key             = local.params.minio.root_password
    server_side_encryption = ""
    calendar               = "*:0/10"  # every 10 minutes
    bucket                 = "smrtlink-backup"
    ca_cert                = file("../shared/minio_ca.crt")
    symlinks               = "skip"
  }
}
