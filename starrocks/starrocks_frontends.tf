locals {
  fe_nodes = ["1", "2", "3"]
}

resource "libvirt_volume" "fe_nodes" {
  for_each         = toset(local.fe_nodes)
  name             = "ferlab-starrocks-fe-${each.key}"
  pool             = "default"
  size             = 30 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2024-03-01"
  format           = "qcow2"
}

module "fe_nodes" {
  for_each = toset(local.fe_nodes)
  source   = "./terraform-libvirt-starrocks-server"
  name     = "ferlab-starrocks-fe-${each.key}"
  hostname = {
    hostname   = "starrocks-server-fe-${each.key}.ferlab.lan"
    is_fqdn    = true
  }
  vcpus            = local.params.starrocks.fe_nodes.vcpus
  memory           = local.params.starrocks.fe_nodes.memory
  volume_id        = libvirt_volume.fe_nodes[each.key].id
  libvirt_networks = [{
    network_name  = "ferlab"
    network_id    = ""
    ip            = element(netaddr_address_ipv4.fe_nodes.*.address, each.key - 1)
    mac           = element(netaddr_address_mac.fe_nodes.*.address, each.key - 1)
    gateway       = local.params.network.gateway
    dns_servers   = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key   = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password    = local.params.virsh_console_password

  fluentbit = {
    enabled           = local.params.logs_forwarding
    starrocks_tag     = "starrocks-fe-${each.key}-starrocks"
    node_exporter_tag = "starrocks-fe-${each.key}-node-exporter"
    metrics = {
      enabled   = true
      port      = 2020
    }
    forward = {
      domain     = local.host_params.ip
      port       = 4443
      hostname   = "starrocks-fe-${each.key}"
      shared_key = local.params.logs_forwarding ? file("${path.module}/../shared/logs_shared_key") : ""
      ca_cert    = local.params.logs_forwarding ? file("${path.module}/../shared/logs_ca.crt") : ""
    }
  }

  starrocks = {
    node_type   = "fe"
    fe_config   = {
      initial_leader = {
        enabled           = each.key == "1" ? true : false
        fe_follower_fqdns = local.fe_follower_fqdns
        be_fqdns          = local.be_fqdns
        root_password     = local.params.starrocks.root_password
      }
      initial_follower = {
        enabled            = each.key != "1" ? true : false
        fe_leader_fqdn     = local.fe_leader_fqdn
      }
      ssl = {
        enabled           = true
        cert              = tls_locally_signed_cert.starrocks_certificate.cert_pem
        key               = tls_private_key.starrocks_key.private_key_pem
        keystore_password = local.params.starrocks.ssl_keystore_password
      }
    }
  }
}
