#First argument should be an fs path, second argument should be a bucket and optional third argument should be tenant number (1 or 2)
if [[ "$3" == "2" ]]; then
  rclone sync --links --config minio_rclone.conf --ca-cert minio_ca.crt $1 "local_dev_minio_tenant2:$2"
else
  rclone sync --links --config minio_rclone.conf --ca-cert minio_ca.crt $1 "local_dev_minio:$2"
fi