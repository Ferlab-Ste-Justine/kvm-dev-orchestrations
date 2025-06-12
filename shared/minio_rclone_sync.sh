#First argument should be an fs path and second argument should be a bucket
rclone sync --config minio_rclone.conf --ca-cert minio_ca.crt $1 local_dev_minio:$2