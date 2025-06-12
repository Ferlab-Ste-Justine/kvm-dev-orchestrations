#First argument should be an fs path and second argument should be a bucket
rclone check --config minio_rclone.conf --ca-cert minio_ca.crt --download $1 local_dev_minio:$2