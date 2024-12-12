locals {
    s3_conf = yamldecode(file("s3-conf.yml"))
}

resource "local_file" "config" {
  content         = templatefile(
    "${path.module}/templates/config.yml.tpl",
    {
      etcd_endpoints = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
      s3 = {
        endpoint = local.s3_conf.endpoint
        bucket = local.s3_conf.bucket
        region = local.s3_conf.region
      }
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/../work-env/config.yml"
  depends_on = [
    null_resource.setup
  ]
}

resource "local_file" "etcd_password" {
  content         = templatefile(
    "${path.module}/templates/etcd_password.yml.tpl",
    {
      username = "root"
      password = file("${path.module}/../../shared/etcd-root_password")
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/../work-env/etcd_password.yml"
  depends_on = [
    null_resource.setup
  ]
}

resource "local_file" "s3_keys" {
  content         = templatefile(
    "${path.module}/templates/s3_keys.yml.tpl",
    {
      access_key = local.s3_conf.access_key
      secret_key = local.s3_conf.secret_key
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/../work-env/s3_keys.yml"
  depends_on = [
    null_resource.setup
  ]
}