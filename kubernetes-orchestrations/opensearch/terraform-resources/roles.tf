resource "opensearch_role" "ui_dashboards_only" {
  role_name = "ui_dashboards_only"

  cluster_permissions = ["indices:data/read/mget"]
}

resource "opensearch_role" "read_test_kubernetes" {
  role_name = "read_test_kubernetes"

  index_permissions {
    index_patterns  = ["test-kubernetes*"]
    allowed_actions = ["read"]
  }

  index_permissions {
    index_patterns          = [".dashboard_*"]
    allowed_actions         = ["read"]
    document_level_security = <<EOF
{
  "bool": {
    "should": [
      {
        "bool": {
          "must": [
            {
              "exists": { "field": "dashboard.description" }
            },
            {
              "terms": { "dashboard.description": ["TEST"] }
            }
          ]
        }
      },
      {
        "bool": {
          "must_not": [
            {
              "exists": { "field": "dashboard.description" }
            }
          ]
        }
      }
    ]
  }
}
EOF
  }
}
