MINIO_ROOT_USER=$(cat ../shared/params.json | jq -r ".minio.root_username")
MINIO_ROOT_PASSWORD=$(cat ../shared/params.json | jq -r ".minio.root_password")
docker run -e "MINIO_ROOT_USER=$MINIO_ROOT_USER" -e "MINIO_ROOT_PASSWORD=$MINIO_ROOT_PASSWORD" --network=host --privileged -it --rm -v $(pwd):/opt/workspace -w /opt/workspace -v $(pwd)/../shared:/opt/shared ubuntu:22.04 sh