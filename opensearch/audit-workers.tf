resource "libvirt_volume" "audit_workers" {
  count            = local.audit_enabled ? local.params.opensearch.audit.workers.count : 0
  name             = "ferlab-opensearch-audit-worker-${count.index + 1}"
  pool             = "default"
  size             = 30 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2024-03-01"
  format           = "qcow2"
}

module "audit_workers" {
  count     = local.audit_enabled ? local.params.opensearch.audit.workers.count : 0
  source    = "./terraform-libvirt-opensearch-server"
  name      = "ferlab-opensearch-audit-worker-${count.index + 1}"
  vcpus     = local.params.opensearch.audit.workers.vcpus
  memory    = local.params.opensearch.audit.workers.memory
  volume_id = libvirt_volume.audit_workers[count.index].id
  libvirt_networks = [{
    network_name  = "ferlab"
    network_id    = ""
    ip            = element(netaddr_address_ipv4.audit_workers.*.address, count.index)
    mac           = element(netaddr_address_mac.audit_workers.*.address, count.index)
    gateway       = local.params.network.gateway
    dns_servers   = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key   = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password    = local.params.virsh_console_password

  opensearch = {
    cluster_name                  = local.audit_cluster_name
    cluster_manager               = false
    seed_hosts                    = [for master in netaddr_address_ipv4.audit_masters : master.address]
    initial_cluster_manager_nodes = local.audit_master_hostnames
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
}
