resource "opensearch_dashboard_object" "visualization_of_controls_visualization" {
  for_each = toset(local.data_names)

  index = ".dashboard"
  body  = <<EOF
[
  {
    "_id": "visualization:${each.key}_visualization_of_controls",
    "_source": {
      "type": "visualization",
      "visualization": {
        "title": "${upper(each.key)} - Controls",
        "visState": "{\"type\":\"input_control_vis\",\"aggs\":[],\"params\":{\"controls\":[{\"id\":\"1742228073579\",\"fieldName\":\"kubernetes.namespace_name.keyword\",\"parent\":\"\",\"label\":\"Namespace\",\"type\":\"list\",\"options\":{\"type\":\"terms\",\"multiselect\":true,\"dynamicOptions\":true,\"size\":5,\"order\":\"desc\"},\"indexPatternRefName\":\"control_0_index_pattern\"},{\"id\":\"1742227662632\",\"fieldName\":\"kubernetes.container_name.keyword\",\"parent\":\"1742228073579\",\"label\":\"Container\",\"type\":\"list\",\"options\":{\"type\":\"terms\",\"multiselect\":true,\"dynamicOptions\":true,\"size\":5,\"order\":\"desc\"},\"indexPatternRefName\":\"control_1_index_pattern\"}],\"updateFiltersOnChange\":false,\"useTimeFilter\":false,\"pinFilters\":false}}",
        "kibanaSavedObjectMeta": {
          "searchSourceJSON": "{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"
        }
      },
      "references": [
        {
          "name": "control_0_index_pattern",
          "type": "index-pattern",
          "id": "${split(":", opensearch_dashboard_object.kubernetes_logs_indexpattern[each.key].id)[1]}"
        },
        {
          "name": "control_1_index_pattern",
          "type": "index-pattern",
          "id": "${split(":", opensearch_dashboard_object.kubernetes_logs_indexpattern[each.key].id)[1]}"
        }
      ]
    }
  }
]
EOF
}
