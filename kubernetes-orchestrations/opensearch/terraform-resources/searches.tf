resource "opensearch_dashboard_object" "search_by_message_search" {
  for_each = toset(local.data_names)

  index = ".dashboard"
  body  = <<EOF
[
  {
    "_id": "search:${each.key}_search_by_message",
    "_source": {
      "type": "search",
      "search": {
        "title": "${upper(each.key)} - Data",
        "columns": [
          "kubernetes.pod_name",
          "message"
        ],
        "kibanaSavedObjectMeta": {
          "searchSourceJSON": "{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"highlightAll\":true,\"version\":true,\"aggs\":{\"2\":{\"date_histogram\":{\"field\":\"@timestamp\",\"fixed_interval\":\"30s\",\"time_zone\":\"America/Toronto\",\"min_doc_count\":1}}},\"filter\":[],\"indexRefName\":\"kibanaSavedObjectMeta.searchSourceJSON.index\"}"
        }
      },
      "references": [
        {
          "name": "kibanaSavedObjectMeta.searchSourceJSON.index",
          "type": "index-pattern",
          "id": "${split(":", opensearch_dashboard_object.kubernetes_logs_indexpattern[each.key].id)[1]}"
        }
      ]
    }
  }
]
EOF
}
