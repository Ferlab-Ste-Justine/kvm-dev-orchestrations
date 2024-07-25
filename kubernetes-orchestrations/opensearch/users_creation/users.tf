resource "opensearch_user" "admin" {
  username = "admin"
  password = "test"
}

resource "opensearch_role_mapping" "admin" {
  role  = "all_access"
  users = [opensearch_user.admin.id]
  hosts = ["*"]
}
