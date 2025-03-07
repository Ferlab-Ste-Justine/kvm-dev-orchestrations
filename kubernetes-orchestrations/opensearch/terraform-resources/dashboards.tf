resource "opensearch_dashboard_object" "kubernetes_logs_dashboard" {
  for_each = toset(local.data_names)

  index = ".dashboard"
  body  = <<EOF
[
  {
    "_id": "dashboard:${each.key}_dashboard",
    "_source": {
      "type": "dashboard",
      "dashboard": {
        "title": "${upper(each.key)} - Kubernetes Logs",
        "description": "${upper(each.key)}",
        "panelsJSON": "[{\"version\":\"2.19.1\",\"gridData\":{\"x\":0,\"y\":0,\"w\":48,\"h\":6,\"i\":\"0d280674-d4b9-46ea-a4b3-3e6502272cba\"},\"panelIndex\":\"0d280674-d4b9-46ea-a4b3-3e6502272cba\",\"embeddableConfig\":{},\"panelRefName\":\"panel_0\"},{\"version\":\"2.19.1\",\"gridData\":{\"x\":0,\"y\":6,\"w\":48,\"h\":169,\"i\":\"4bbb9d2a-24a6-40f9-b456-98838b775bcf\"},\"panelIndex\":\"4bbb9d2a-24a6-40f9-b456-98838b775bcf\",\"embeddableConfig\":{},\"panelRefName\":\"panel_1\"}]",
        "optionsJSON": "{\"hidePanelTitles\":false,\"useMargins\":true}"
      },
      "references": [
        {
          "name": "panel_0",
          "type": "visualization",
          "id": "${split(":", opensearch_dashboard_object.visualization_of_controls_visualization[each.key].id)[1]}"
        },
        {
          "name": "panel_1",
          "type": "search",
          "id": "${split(":", opensearch_dashboard_object.search_by_message_search[each.key].id)[1]}"
        }
      ]
    }
  }
]
EOF
}
