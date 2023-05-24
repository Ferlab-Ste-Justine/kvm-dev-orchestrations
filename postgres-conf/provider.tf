provider "postgresql" {
  host     = "load-balancer.postgres.ferlab.lan"
  database = "postgres"
  username = "postgres"
  password = file("${path.module}/../shared/postgres_root_password")
  sslmode  = "verify-full"
  sslrootcert = "${path.module}/../shared/postgres_ca.crt"
  superuser = true
  expected_version = "14.5"
}