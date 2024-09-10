resource "opensearch_user" "admin" {
  provider = opensearch-ferlab

  username = "admin"
  password = "test"
}

resource "opensearch_role_mapping" "admin" {
  provider = opensearch-ferlab

  role  = "all_access"
  users = [opensearch_user.admin.id]
}
