resource "opensearch_user" "admin" {
  provider = opensearch-ferlab

  username = "admin"
  password = "ferlabteam"
}

resource "opensearch_role_mapping" "admin" {
  provider = opensearch-ferlab

  role  = "all_access"
  users = [opensearch_user.admin.id]
}

resource "opensearch_user" "test" {
  provider = opensearch-ferlab

  username = "test"
  password = "ferlabteam"
}

# resource "opensearch_role_mapping" "test" {
#   provider = opensearch-ferlab
#
#   role  = opensearch_role.ui_dashboards_only.id
#   users = [opensearch_user.test.id]
# }
