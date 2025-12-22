locals {
  primary_cluster_ips = [
    for server in concat(
      netaddr_address_ipv4.masters,
      netaddr_address_ipv4.workers
    ) : server.address
  ]

  audit_cluster_ips = [
    for server in concat(
      netaddr_address_ipv4.audit_masters,
      netaddr_address_ipv4.audit_workers
    ) : server.address
  ]

  primary_cluster_domains = [
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

  audit_cluster_domains = [
    "audit-opensearch",
    "audit-opensearch-masters",
    "audit-opensearch-workers",
    local.audit_domain,
    "masters.${local.audit_domain}",
    "workers.${local.audit_domain}",
    "${local.resources_namespace}-opensearch-audit",
    "${local.resources_namespace}-opensearch-audit-masters",
    "${local.resources_namespace}-opensearch-audit-workers"
  ]
}

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

resource "tls_private_key" "audit_ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_private_key" "audit_server" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_private_key" "audit_admin" {
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

  cluster_ips     = local.primary_cluster_ips
  cluster_domains = local.primary_cluster_domains
}

module "audit_certificates" {
  source            = "./terraform-tls-opensearch-certificates"
  organization      = "ferlab"
  node_common_name  = local.audit_domain
  admin_common_name = "admin"
  ca_key            = tls_private_key.audit_ca.private_key_pem
  server_key        = tls_private_key.audit_server.private_key_pem
  admin_key         = tls_private_key.audit_admin.private_key_pem
  cluster_ips       = local.audit_cluster_ips
  cluster_domains   = local.audit_cluster_domains
}

resource "local_file" "ca_certificate_shared" {
  content         = module.certificates.ca_certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/opensearch-ca.crt"
}

resource "local_file" "ca_certificate_kubernetes" {
  content         = module.certificates.ca_certificate
  file_permission = "0600"
  filename        = "${path.module}/../kubernetes-orchestrations/opensearch/certificates/opensearch-ca.crt"
}

resource "local_file" "admin_certificate_shared" {
  content         = module.certificates.admin_certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/opensearch.crt"
}

resource "local_file" "admin_certificate_kubernetes" {
  content         = module.certificates.admin_certificate
  file_permission = "0600"
  filename        = "${path.module}/../kubernetes-orchestrations/opensearch/certificates/opensearch.crt"
}

resource "local_file" "admin_key_shared" {
  content         = tls_private_key.admin.private_key_pem
  file_permission = "0600"
  filename        = "${path.module}/../shared/opensearch.key"
}

resource "local_file" "admin_key_kubernetes" {
  content         = tls_private_key.admin.private_key_pem
  file_permission = "0600"
  filename        = "${path.module}/../kubernetes-orchestrations/opensearch/certificates/opensearch.key"
}

resource "local_file" "audit_ca_certificate_shared" {
  content         = module.audit_certificates.ca_certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/opensearch-audit-ca.crt"
}

resource "local_file" "audit_admin_certificate_shared" {
  content         = module.audit_certificates.admin_certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/opensearch-audit.crt"
}

resource "local_file" "audit_admin_key_shared" {
  content         = tls_private_key.audit_admin.private_key_pem
  file_permission = "0600"
  filename        = "${path.module}/../shared/opensearch-audit.key"
}
