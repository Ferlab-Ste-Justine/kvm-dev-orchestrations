resource "opensearch_dashboard_object" "dashboard_indexpattern" {
  index = ".dashboard"
  body  = <<EOF
[
  {
    "_id": "index-pattern:dashboard",
    "_source": {
      "type": "index-pattern",
      "index-pattern": {
        "title": ".dashboard_*"
      }
    }
  }
]
EOF
}

resource "opensearch_dashboard_object" "kubernetes_logs_indexpattern" {
  for_each = toset(local.data_names)

  index = ".dashboard"
  body  = <<EOF
[
  {
    "_id": "index-pattern:${each.key}-kubernetes-logs",
    "_source": {
      "type": "index-pattern",
      "index-pattern": {
        "title": "${each.key}-kubernetes*",
        "timeFieldName": "@timestamp"
      }
    }
  }
]
EOF
}
