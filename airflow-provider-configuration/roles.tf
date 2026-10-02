resource "airflow_fab_role" "test" {
  name       = "troubleshoot_role"
  permissions = [
    {
      action   = "can_read"
      resource = "Website"
    },
    {
      action   = "can_read"
      resource = "DAGs"
    }
  ] 
}