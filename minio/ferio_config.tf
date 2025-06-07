locals {
  minio_release = local.params.minio.ferio_update_release ? {
    version  = "2024-04-06"
    url      = "https://dl.min.io/server/minio/release/linux-amd64/archive/minio.RELEASE.2024-04-06T05-26-02Z"
    checksum = "71cc26f16787b7e54001327eaefa0227bff13e9f28c117aafa15dc23733c9584"
  } : {
    version  = "2023-12-23"
    url      = "https://dl.min.io/server/minio/release/linux-amd64/archive/minio.RELEASE.2023-12-23T07-19-11Z"
    checksum = "8a5d296b5ef251e4b7e52c71776f33a060e05b56322312bccabd4e2739e8a6a3"
  }
  server_pools = local.params.minio.extra_server_pool ? {
    version = "2024-01-11"
    pools = [
      {
        api_port            = 9000
        domain_template     = "server%s.minio.ferlab.lan"
        server_count_begin  = 1
        server_count_end    = 4
        mount_path_template = "/opt/mnt/volume%s"
        mount_count         = 2
      },
      {
        api_port            = 9000
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
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-ferio-configuration.git"
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