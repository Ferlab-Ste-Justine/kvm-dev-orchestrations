module "kubernetes_logs" {
  source = "./terraform-opensearch-dashboard-object/index-pattern"
  id            = "index-pattern:ferlab-kubernetes-logs"
  index_pattern = "ferlab-kubernetes*"
}

module "minio_audit_notifications_logs" {
  source = "./terraform-opensearch-dashboard-object/index-pattern"
  id            = "index-pattern:minio-audit-notifications"
  index_pattern = "minio-audit-notifications*"
}
