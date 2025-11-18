locals {
  params              = jsondecode(file("${path.module}/../shared/params.json"))
  domain              = "opensearch.ferlab.lan"
  resources_namespace = "ferlab"

  audit_enabled      = try(local.params.opensearch.audit_cluster_enabled, false)

  audit_cluster_name = "${local.resources_namespace}-opensearch-audit"
  audit_domain       = "audit.${local.domain}"

  audit_storage_type = local.audit_enabled ? "external_opensearch" : "internal_opensearch"

  master_hostnames = [
    for idx in range(local.params.opensearch.masters.count) :
    "ferlab-opensearch-master-${idx + 1}"
  ]

  audit_master_hostnames = local.audit_enabled ? [
    for idx in range(local.params.opensearch.audit.masters.count) :
    "ferlab-opensearch-audit-master-${idx + 1}"
  ] : []
}
