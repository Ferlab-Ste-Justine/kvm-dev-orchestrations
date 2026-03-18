resource "kubernetes_secret" "opensearch_client_credentials" {
  metadata {
    name = "opensearch-client-credentials"
    namespace = "minio-audit-logs"
  }

  data = {
    "ca.crt" = fileexists("${path.module}/../../../shared/opensearch-ca.crt") ? file("${path.module}/../../../shared/opensearch-ca.crt") : ""
    "client.crt" = fileexists("${path.module}/../../../shared/opensearch.crt") ? file("${path.module}/../../../shared/opensearch.crt") : ""
    "client.key" = fileexists("${path.module}/../../../shared/opensearch.key") ? file("${path.module}/../../../shared/opensearch.key") : ""
  }

  depends_on = [kubernetes_namespace.minio_audit_logs]
}