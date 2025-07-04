[local_dev_minio]
type = s3
provider = Minio
env_auth = false
access_key_id = ${root_username}
secret_access_key = ${root_password}
region = us-east-1
endpoint = https://minio.ferlab.lan:9000
location_constraint =
server_side_encryption = aws:kms

[local_dev_minio_tenant2]
type = s3
provider = Minio
env_auth = false
access_key_id = ${root_username}
secret_access_key = ${root_password}
region = us-east-1
endpoint = https://minio.ferlab.lan:9002
location_constraint =
server_side_encryption = aws:kms
