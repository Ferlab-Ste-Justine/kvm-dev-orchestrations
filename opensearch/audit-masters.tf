resource "libvirt_volume" "audit_masters" {
  count            = local.audit_enabled ? local.params.opensearch.audit.masters.count : 0
  name             = "ferlab-opensearch-audit-master-${count.index + 1}"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2024-03-01"
  format           = "qcow2"
}

module "audit_first_master" {
  count     = local.audit_enabled ? 1 : 0
  source    = "./terraform-libvirt-opensearch-server"
  name      = "ferlab-opensearch-audit-master-1"
  vcpus     = local.params.opensearch.audit.masters.vcpus
  memory    = local.params.opensearch.audit.masters.memory
  volume_id = libvirt_volume.audit_masters[0].id
  libvirt_networks = [{
    network_name  = "ferlab"
    network_id    = ""
    ip            = element(netaddr_address_ipv4.audit_masters.*.address, 0)
    mac           = element(netaddr_address_mac.audit_masters.*.address, 0)
    gateway       = local.params.network.gateway
    dns_servers   = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key   = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password    = local.params.virsh_console_password

  opensearch = {
    cluster_name                  = local.audit_cluster_name
    cluster_manager               = true
    seed_hosts                    = [for master in netaddr_address_ipv4.audit_masters : master.address]
    initial_cluster_manager_nodes = local.audit_master_hostnames
    initial_cluster               = true
    bootstrap_security            = true

    auth_dn_fields = {
      admin_common_name = "admin"
      node_common_name  = local.audit_domain
      organization      = "ferlab"
    }

    verify_domains     = true
    basic_auth_enabled = true

    tls = {
      ca_certificate = module.audit_certificates.ca_certificate
      server = {
        key         = tls_private_key.audit_server.private_key_pem
        certificate = module.audit_certificates.server_certificate
      }
      admin_client = {
        key         = tls_private_key.audit_admin.private_key_pem
        certificate = module.audit_certificates.admin_certificate
      }
    }

    audit = {
      enabled      = true
      index        = "security-auditlog"
      ignore_users = []
    }
  }
  snapshot_repository = local.audit_snapshot_repository
}

module "audit_other_masters" {
  count     = local.audit_enabled ? (local.params.opensearch.audit.masters.count - 1) : 0
  source    = "./terraform-libvirt-opensearch-server"
  name      = "ferlab-opensearch-audit-master-${count.index + 2}"
  vcpus     = local.params.opensearch.audit.masters.vcpus
  memory    = local.params.opensearch.audit.masters.memory
  volume_id = libvirt_volume.audit_masters[count.index + 1].id
  libvirt_networks = [{
    network_name  = "ferlab"
    network_id    = ""
    ip            = element(netaddr_address_ipv4.audit_masters.*.address, count.index + 1)
    mac           = element(netaddr_address_mac.audit_masters.*.address, count.index + 1)
    gateway       = local.params.network.gateway
    dns_servers   = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key   = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password    = local.params.virsh_console_password

  opensearch = {
    cluster_name                  = local.audit_cluster_name
    cluster_manager               = true
    seed_hosts                    = [for master in netaddr_address_ipv4.audit_masters : master.address]
    initial_cluster_manager_nodes = local.audit_master_hostnames
    initial_cluster               = true
    bootstrap_security            = false

    auth_dn_fields = {
      admin_common_name = "admin"
      node_common_name  = local.audit_domain
      organization      = "ferlab"
    }

    verify_domains     = true
    basic_auth_enabled = true

    tls = {
      ca_certificate = module.audit_certificates.ca_certificate
      server = {
        key         = tls_private_key.audit_server.private_key_pem
        certificate = module.audit_certificates.server_certificate
      }
      admin_client = {
        key         = tls_private_key.audit_admin.private_key_pem
        certificate = module.audit_certificates.admin_certificate
      }
    }

    audit = {
      enabled      = true
      index        = "security-auditlog"
      ignore_users = []
    }
  }
  snapshot_repository = local.audit_snapshot_repository
}
