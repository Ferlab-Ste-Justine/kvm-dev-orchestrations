resource "kubernetes_secret" "slack_token" {
  metadata {
    name = "slack-token"
    namespace = "minio-audit-logs"
  }

  data = {
    SLACK_TOKEN = fileexists("${path.module}/../../../shared/slack_token") ? file("${path.module}/../../../shared/slack_token") : ""
    SLACK_CHANNEL  = fileexists("${path.module}/../../../shared/slack_alert_channel") ? file("${path.module}/../../../shared/slack_alert_channel") : ""
  }

  depends_on = [kubernetes_namespace.minio_audit_logs]
}