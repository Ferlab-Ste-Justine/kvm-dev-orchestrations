data "airflow_fab_role" "viewer" {
  name       = "Viewer"
}

output "viewer_role" {
  value = data.airflow_fab_role.viewer
}

data "airflow_fab_user" "admin" {
  username       = "admin"
}

output "admin_user" {
  value = data.airflow_fab_user.admin
}