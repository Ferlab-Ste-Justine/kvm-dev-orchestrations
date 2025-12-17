RESOURCES_PATH=$(cat ./path)
(cd ../../../../shared; ./minio_rclone_sync.sh $RESOURCES_PATH phenovar-resources) 