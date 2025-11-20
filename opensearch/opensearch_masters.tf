resource "libvirt_volume" "masters" {
  count            = local.params.opensearch.masters.count
  name             = "ferlab-opensearch-master-${count.index + 1}"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2024-03-01"
  format           = "qcow2"
}

module "first_master" {
  source    = "./terraform-libvirt-opensearch-server"
  name      = "ferlab-opensearch-master-1"
  vcpus     = local.params.opensearch.masters.vcpus
  memory    = local.params.opensearch.masters.memory
  volume_id = libvirt_volume.masters[0].id
  libvirt_networks = [{
    network_name  = "ferlab"
    network_id    = ""
    ip            = element(netaddr_address_ipv4.masters.*.address, 0)
    mac           = element(netaddr_address_mac.masters.*.address, 0)
    gateway       = local.params.network.gateway
    dns_servers   = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key   = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password    = local.params.virsh_console_password
  opensearch = {
    cluster_name                  = "${local.resources_namespace}-opensearch"
    cluster_manager               = true
    seed_hosts                    = [for master in netaddr_address_ipv4.masters : master.address]
    initial_cluster_manager_nodes = local.master_hostnames
    initial_cluster               = true
    bootstrap_security            = true
    auth_dn_fields = {
      admin_common_name = "admin"
      node_common_name  = local.domain
      organization      = "ferlab"
    }
    verify_domains     = true
    basic_auth_enabled = true
    tls = {
      ca_certificate = module.certificates.ca_certificate
      server = {
        key         = tls_private_key.server.private_key_pem
        certificate = module.certificates.server_certificate
      }
      admin_client = {
        key         = tls_private_key.admin.private_key_pem
        certificate = module.certificates.admin_certificate
      }
    }
    audit = {
      enabled      = true
      index        = "security-auditlog"
      ignore_users = []
      external = local.audit_enabled ? {
        http_endpoints = ["${local.audit_domain}:9200"]
        auth = {
          ca_cert     = module.certificates.ca_certificate
          client_cert = module.certificates.admin_certificate
          client_key  = tls_private_key.admin.private_key_pem
        }
      } : null
    }
  }
}

module "other_masters" {
  count     = local.params.opensearch.masters.count - 1
  source    = "./terraform-libvirt-opensearch-server"
  name      = "ferlab-opensearch-master-${count.index + 2}"
  vcpus     = local.params.opensearch.masters.vcpus
  memory    = local.params.opensearch.masters.memory
  volume_id = libvirt_volume.masters[count.index + 1].id
  libvirt_networks = [{
    network_name  = "ferlab"
    network_id    = ""
    ip            = element(netaddr_address_ipv4.masters.*.address, count.index + 1)
    mac           = element(netaddr_address_mac.masters.*.address, count.index + 1)
    gateway       = local.params.network.gateway
    dns_servers   = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key   = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password    = local.params.virsh_console_password
  opensearch = {
    cluster_name                  = "${local.resources_namespace}-opensearch"
    cluster_manager               = true
    seed_hosts                    = [for master in netaddr_address_ipv4.masters : master.address]
    initial_cluster_manager_nodes = local.master_hostnames
    initial_cluster               = true
    bootstrap_security            = false
    auth_dn_fields = {
      admin_common_name = "admin"
      node_common_name  = local.domain
      organization      = "ferlab"
    }
    verify_domains     = true
    basic_auth_enabled = true
    tls = {
      ca_certificate = module.certificates.ca_certificate
      server = {
        key         = tls_private_key.server.private_key_pem
        certificate = module.certificates.server_certificate
      }
      admin_client = {
        key         = tls_private_key.admin.private_key_pem
        certificate = module.certificates.admin_certificate
      }
    }
    audit = {
      enabled      = true
      index        = "security-auditlog"
      ignore_users = []
      external = local.audit_enabled ? {
        http_endpoints = ["${local.audit_domain}:9200"]
        auth = {
          ca_cert     = module.certificates.ca_certificate
          client_cert = module.certificates.admin_certificate
          client_key  = tls_private_key.admin.private_key_pem
        }
      } : null
    }
  }
}
