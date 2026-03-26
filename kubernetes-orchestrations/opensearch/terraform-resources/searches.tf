module "minio_audit_notifications_logs_search" {
  source = "./terraform-opensearch-dashboard-object/search"
  id             = "minio-audit-notifications"
  title          = "minio-audit-notifications"
  columns        = ["account", "event", "details"]
  index_patterns = ["minio-audit-notifications"]

  depends_on = [module.minio_audit_notifications_logs]
}