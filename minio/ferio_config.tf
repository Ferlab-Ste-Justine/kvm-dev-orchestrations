locals {
  minio_release = local.params.minio.ferio_update_release ? {
    version  = "2025-04-03"
    url      = "https://dl.min.io/server/minio/release/linux-amd64/archive/minio.RELEASE.2025-04-03T14-56-28Z"
    checksum = "cebd628ae859b4670de9c04b0cbf5600a498166da2031ad634c987208d89ae94"
  } : {
    version  = "2023-12-23"
    url      = "https://dl.min.io/server/minio/release/linux-amd64/archive/minio.RELEASE.2023-12-23T07-19-11Z"
    checksum = "8a5d296b5ef251e4b7e52c71776f33a060e05b56322312bccabd4e2739e8a6a3"
  }
  server_pool_tenants = [
    #No tenants
    [],
    #One tenant
    [{
      name = "ferlab"
      api_port = 9000
      data_path = "ferlab"
    }],
    #Two tenants
    [
      {
        name = "ferlab"
        api_port = 9000
        data_path = "ferlab"
      },
      {
        name = "ferlab2"
        api_port = 9002
        data_path = "ferlab2"
      }
    ]
  ]
  server_pools = local.params.minio.extra_server_pool ? {
    version = "2024-01-11"
    pools = [
      {
        api_port            = 9000
        tenants             = element(local.server_pool_tenants, local.params.minio.tenants)
        domain_template     = "server%s.minio.ferlab.lan"
        server_count_begin  = 1
        server_count_end    = 4
        mount_path_template = "/opt/mnt/volume%s"
        mount_count         = 2
      },
      {
        api_port            = 9000
        tenants             = element(local.server_pool_tenants, local.params.minio.tenants)
        domain_template     = "server%s.minio.ferlab.lan"
        server_count_begin  = 5
        server_count_end    = 8
        mount_path_template = "/opt/mnt/volume%s"
        mount_count         = 2
      }
    ]
  } : {
    version = "2024-01-03"
    pools = [
      {
        api_port            = 9000
        tenants             = element(local.server_pool_tenants, local.params.minio.tenants)
        domain_template     = "server%s.minio.ferlab.lan"
        server_count_begin  = 1
        server_count_end    = 4
        mount_path_template = "/opt/mnt/volume%s"
        mount_count         = 2
      }
    ]
  }
}

module "ferio_config" {
  source = "./terraform-etcd-ferio-configuration"
  key_prefix = "/ferlab/ferio/config/"
  minio_release = local.minio_release
  server_pools = local.server_pools
}

data "etcd_prefix_range_end" "ferio" {
    key = "/ferlab/ferio/"
}

resource "etcd_range_scoped_state" "ferio" {
    key = data.etcd_prefix_range_end.ferio.key
    range_end = data.etcd_prefix_range_end.ferio.range_end
    clear_on_creation = false
    clear_on_deletion = true
}