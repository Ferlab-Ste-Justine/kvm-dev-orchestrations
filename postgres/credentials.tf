module "postgres_ca" {
  source = "../ca"
  common_name = "postgres"
}

resource "local_file" "postgres_ca_cert" {
  content         = module.postgres_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/postgres_ca.crt"
}

resource "local_file" "postgres_ca_key" {
  content         = module.postgres_ca.key
  file_permission = "0600"
  filename        = "${path.module}/../shared/postgres_ca.key"
}

resource "random_password" "postgres_root_password" {
  length           = 16
  special          = false
}

resource "local_file" "postgres_root_password" {
  content         = random_password.postgres_root_password.result
  file_permission = "0600"
  filename        = "${path.module}/../shared/postgres_root_password"
}