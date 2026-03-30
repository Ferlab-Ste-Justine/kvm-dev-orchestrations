provider "etcd" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert   = "${path.module}/../shared/etcd-ca.pem"
  username  = "root"
  password  = file("${path.module}/../shared/etcd-root_password")
}

resource "time_rotating" "now" {
  rotation_minutes = 1
}

module "upload_users" {
  source = "./terraform-etcd-ferlab-users/upload"
  etcd_key = "/test-users/users.yml"
  users = yamldecode(file("users.yml"))
  roles = ["dev", "analyst", "admin"]
  environments = ["qa", "staging", "prod"]
  required_attributes = {
    dev     = ["github_user"]
    analyst = ["rstudio_user"]
  }
}

module "download_users" {
  source = "./terraform-etcd-ferlab-users/download"
  etcd_key = "/test-users/users.yml"
  execution_time = time_rotating.now.rfc3339
  compute = {
    users_by_username = true
    users_by_role = true
    usernames_by_role = true
    users_by_environment = true
    usernames_by_environment = true
    users_by_environment_role = true
    usernames_by_environment_role = true
  }
  depends_on = [module.upload_users]
}