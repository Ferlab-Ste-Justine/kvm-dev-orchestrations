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

resource "opensearch_dashboard_object" "test_kubernetes_logs" {
  index = ".dashboard"
  body  = <<EOF
[
  {
    "_id": "index-pattern:test-kubernetes-logs",
    "_source": {
      "type": "index-pattern",
      "index-pattern": {
        "title": "test-kubernetes*",
        "timeFieldName": "@timestamp"
      }
    }
  }
]
EOF
}
