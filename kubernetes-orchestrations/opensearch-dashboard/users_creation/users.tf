resource "opensearch_user" "admin" {
  username = "admin"
  password = "test"
}

resource "opensearch_role_mapping" "cqdg_ops_admin" {
  role  = "all_access"
  users = [opensearch_user.admin.id]
  hosts = ["*"]
}
