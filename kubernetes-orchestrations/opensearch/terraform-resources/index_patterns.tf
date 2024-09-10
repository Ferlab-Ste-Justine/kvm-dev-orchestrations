resource "opensearch_dashboard_object" "ferlab_kubernetes_logs" {
  index = ".dashboard"
  body  = <<EOF
[
  {
    "_id": "index-pattern:ferlab-kubernetes-logs",
    "_source": {
      "type": "index-pattern",
      "index-pattern": {
        "title": "ferlab-kubernetes*",
        "timeFieldName": "@timestamp"
      }
    }
  }
]
EOF
}
