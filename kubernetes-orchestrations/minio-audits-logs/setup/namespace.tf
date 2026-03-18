resource "kubernetes_namespace" "minio_audit_logs" {
  metadata {
    name = "minio-audit-logs"
  }
}