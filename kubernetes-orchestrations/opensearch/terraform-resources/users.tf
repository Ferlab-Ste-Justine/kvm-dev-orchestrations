resource "opensearch_user" "admin" {
  username = "admin"
  password = "ferlabteam"
}

resource "opensearch_roles_mapping" "admin" {
  role_name = "all_access"
  users     = [opensearch_user.admin.id]
}

resource "opensearch_user" "test" {
  username = "test"
  password = "ferlabteam"
}

resource "opensearch_roles_mapping" "test" {
  role_name = opensearch_role.ui_dashboards_only.id
  users     = [opensearch_user.test.id]
}

resource "opensearch_roles_mapping" "test_2" {
  role_name = opensearch_role.read_test_kubernetes.id
  users     = [opensearch_user.test.id]
}
