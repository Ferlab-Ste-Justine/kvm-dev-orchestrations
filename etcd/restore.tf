locals {
  restore_s3_conf = fileexists("${path.module}/../etcd-backup/setup/s3-conf.yml") ? yamldecode(file("${path.module}/../etcd-backup/setup/s3-conf.yml")) : {
    endpoint = ""
    bucket = ""
    region = ""
    access_key = ""
    secret_key = ""
    ca_cert = ""
  }
  restore_enabled = false
  restore_backup_timestamp = ""
  restore_encryption_key = fileexists("${path.module}/../etcd-backup/work-env/etcd-backup-master-1.key") ? file("${path.module}/../etcd-backup/work-env/etcd-backup-master-1.key") : ""
}