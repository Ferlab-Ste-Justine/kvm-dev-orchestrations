resource "libvirt_volume" "dhcp" {
  name             = "ferlab-dhcp"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format = "qcow2"
}

module "dhcp" {
  source = "./terraform-libvirt-dhcp-server"
  name = "ferlab-dhcp"
  vcpus = local.params.dhcp.vcpus
  memory = local.params.dhcp.memory
  volume_id = libvirt_volume.dhcp.id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = netaddr_address_ipv4.dhcp.address
    mac = netaddr_address_mac.dhcp.address
    prefix_length = split("/", local.params.network.addresses).1
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.address]
  }
  dhcp = {
    networks = [{
      addresses   = local.params.network.addresses
      gateway     = local.params.network.gateway
      broadcast   = local.params.network.broadcast
      dns_servers = [data.netaddr_address_ipv4.coredns.address]
      range_start = local.params.network.dhcp_range.start
      range_end   = local.params.network.dhcp_range.end
    }]
  }
  pxe = {
    enabled = true
    self_url = netaddr_address_ipv4.dhcp.address
    static_boot_script = ""
    boot_script_path = "scripts/ipxe-boot-script"
  }
  s3_sync = {
    enabled  = true
    url_path = "os"
    s3       = {
      bucket                 = "pxe"
      url                    = "https://minio.ferlab.lan:9000"
      region                 = "us-east-1"
      server_side_encryption = ""
      auth                   = {
        ca_cert    = file("${path.module}/../shared/minio_ca.crt")
        access_key = local.params.minio.root_username
        secret_key = local.params.minio.root_password
      }
    }
  }
  etcd_sync = {
    enabled  = true
    url_path = "scripts"
    etcd     = {
      key_prefix = data.etcd_prefix_range_end.pxe.key
      endpoints  = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
      auth       = {
        ca_certificate     = file("${path.module}/../shared/etcd-ca.pem")
        client_certificate = ""
        client_key         = ""
        username           = etcd_role.pxe.name
        password           = random_password.pxe_etcd_password.result
      }
    }
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
}