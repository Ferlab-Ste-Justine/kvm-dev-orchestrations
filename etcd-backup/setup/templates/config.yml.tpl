etcd_client:
  endpoints:
%{ for endpoint in etcd_endpoints ~}
    - "${endpoint}"
%{ endfor ~}
  connection_timeout: "1m"
  request_timeout: "1m"
  retries: 3 
  auth:
    ca_cert: "../../shared/etcd-ca.pem"
    password_auth: "etcd_password.yml"
snapshot_path: "snapshots/snapshot"
encryption_key_path: "etcd-backup-master-1.key"
s3_client:
  objects_prefix: "backup"
  endpoint: "${s3.endpoint}"
  bucket: "${s3.bucket}"
  auth:
    key_auth: "s3_keys.yml"
  region: "${s3.region}"
  connection_timeout: "1m"
  request_timeout: "1m"
log_level: "info"