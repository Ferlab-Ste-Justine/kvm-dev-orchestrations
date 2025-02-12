resource "minio_s3_bucket" "smrtlink_backup" {
  count         = local.params.smrtlink.s3_backups ? 1 : 0
  bucket        = "smrtlink-backup"
  acl           = "private"
  force_destroy = null
}
