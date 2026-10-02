resource "airflow_fab_user" "test" {
  username   = "troubleshoot_user"
  password   = "TempPass123!!"
  email      = "troubleshoot@example.com"
  first_name = "Troubleshoot"
  last_name  = "User"
  roles      = ["User", airflow_fab_role.test.name]
}