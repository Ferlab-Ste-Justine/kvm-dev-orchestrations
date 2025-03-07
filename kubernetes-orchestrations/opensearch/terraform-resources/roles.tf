resource "opensearch_role" "ui_dashboards_only" {
  provider = opensearch-ferlab

  name = "ui_dashboards_only"
}
