resource "tls_private_key" "ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_private_key" "server" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_private_key" "admin" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

module "certificates" {
  source            = "./terraform-tls-opensearch-certificates"
  organization      = "ferlab"
  node_common_name  = local.domain
  admin_common_name = "admin"
  ca_key            = tls_private_key.ca.private_key_pem
  server_key        = tls_private_key.server.private_key_pem
  admin_key         = tls_private_key.admin.private_key_pem
  cluster_ips       = [for server in concat(netaddr_address_ipv4.masters, netaddr_address_ipv4.workers) : server.address]
  cluster_domains = [
    "opensearch",
    "opensearch-masters",
    "opensearch-workers",
    local.domain,
    "masters.${local.domain}",
    "workers.${local.domain}",
    "${local.resources_namespace}-opensearch",
    "${local.resources_namespace}-opensearch-masters",
    "${local.resources_namespace}-opensearch-workers"
  ]
}

resource "local_file" "ca_certificate_shared" {
  content         = module.certificates.ca_certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/opensearch-ca.crt"
}

resource "local_file" "ca_certificate_dashboard" {
  content         = module.certificates.ca_certificate
  file_permission = "0600"
  filename        = "${path.module}/../kubernetes-orchestrations/opensearch-dashboard/certificates/opensearch-ca.crt"
}

resource "local_file" "admin_certificate_shared" {
  content         = module.certificates.admin_certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/opensearch.crt"
}

resource "local_file" "admin_certificate_dashboard" {
  content         = module.certificates.admin_certificate
  file_permission = "0600"
  filename        = "${path.module}/../kubernetes-orchestrations/opensearch-dashboard/certificates/opensearch.crt"
}

resource "local_file" "admin_key_shared" {
  content         = tls_private_key.admin.private_key_pem
  file_permission = "0600"
  filename        = "${path.module}/../shared/opensearch.key"
}

resource "local_file" "admin_key_dashboard" {
  content         = tls_private_key.admin.private_key_pem
  file_permission = "0600"
  filename        = "${path.module}/../kubernetes-orchestrations/opensearch-dashboard/certificates/opensearch.key"
}
