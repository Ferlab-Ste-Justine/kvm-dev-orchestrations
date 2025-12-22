locals {
  params              = jsondecode(file("${path.module}/../shared/params.json"))
  domain              = "opensearch.ferlab.lan"
  resources_namespace = "ferlab"

  audit_enabled = try(local.params.opensearch.audit_cluster_enabled, false)

  audit_cluster_name = "${local.resources_namespace}-opensearch-audit"
  audit_domain       = "audit.${local.domain}"

  default_snapshot_repository = {
    access_key = ""
    secret_key = ""
    ca_certs   = []
  }

  minio_snapshot_ca_certs = [
    trimspace(file("${path.module}/../shared/minio_ca.crt"))
  ]

  opensearch_snapshot_repository = merge(
    local.default_snapshot_repository,
    try(local.params.opensearch.snapshot_repository, {}),
    {
      ca_certs = distinct(concat(
        try(local.params.opensearch.snapshot_repository.ca_certs, []),
        local.minio_snapshot_ca_certs
      ))
    }
  )

  audit_snapshot_repository = merge(
    local.default_snapshot_repository,
    try(local.params.opensearch.audit.snapshot_repository, {}),
    {
      ca_certs = distinct(concat(
        try(local.params.opensearch.audit.snapshot_repository.ca_certs, []),
        local.minio_snapshot_ca_certs
      ))
    }
  )

  master_hostnames = [
    for idx in range(local.params.opensearch.masters.count) :
    "ferlab-opensearch-master-${idx + 1}"
  ]

  audit_master_hostnames = local.audit_enabled ? [
    for idx in range(local.params.opensearch.audit.masters.count) :
    "ferlab-opensearch-audit-master-${idx + 1}"
  ] : []
}
