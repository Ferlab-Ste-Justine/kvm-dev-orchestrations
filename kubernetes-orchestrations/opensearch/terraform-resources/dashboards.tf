module "minio_audit_notifications_logs_dashboard" {
  source = "./terraform-opensearch-dashboard-object/dashboard"
  id            = "minio-audit-notifications"
  title         = "minio-audition-notifications-dashboard"
  search_panels = [{
    search_id = "minio-audit-notifications"
    top       = 0
    left      = 0
    width     = 48
    height    = 28
  }]

  depends_on = [module.minio_audit_notifications_logs_search]
}