provider "etcd" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert   = "${path.module}/../shared/etcd-ca.pem"
  username  = "root"
  password  = file("${path.module}/../shared/etcd-root_password")
}

resource "time_static" "now" {}

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
  execution_time = time_static.now.rfc3339
  depends_on = [module.upload_users]
}