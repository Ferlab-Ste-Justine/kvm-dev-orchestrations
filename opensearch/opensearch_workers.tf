resource "libvirt_volume" "workers" {
  count            = local.params.opensearch.workers.count
  name             = "ferlab-opensearch-worker-${count.index + 1}"
  pool             = "default"
  size             = 30 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2024-03-01"
  format           = "qcow2"
}

module "workers" {
  count     = local.params.opensearch.workers.count
  source    = "./terraform-libvirt-opensearch-server"
  name      = "ferlab-opensearch-worker-${count.index + 1}"
  vcpus     = local.params.opensearch.workers.vcpus
  memory    = local.params.opensearch.workers.memory
  volume_id = libvirt_volume.workers[count.index].id
  libvirt_networks = [{
    network_name  = "ferlab"
    network_id    = ""
    ip            = element(netaddr_address_ipv4.workers.*.address, count.index)
    mac           = element(netaddr_address_mac.workers.*.address, count.index)
    gateway       = local.params.network.gateway
    dns_servers   = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key   = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password    = local.params.virsh_console_password
  opensearch = {
    cluster_name                  = "${local.resources_namespace}-opensearch"
    cluster_manager               = false
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
          ca_cert     = module.audit_certificates.ca_certificate
          client_cert = module.audit_certificates.admin_certificate
          client_key  = tls_private_key.audit_admin.private_key_pem
        }
      } : null
    }
  }
  snapshot_repository = local.opensearch_snapshot_repository
}
