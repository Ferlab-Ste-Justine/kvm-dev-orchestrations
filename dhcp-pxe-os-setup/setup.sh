#!/bin/sh

if [ ! -d "image" ] || [ ! -d "bin" ]
then
    apt-get update
    apt-get install -y wget unzip
fi

if [ ! -d "image" ] 
then
    mkdir image
    wget -O image/ubuntu-22.04-server-amd64.iso https://releases.ubuntu.com/jammy/ubuntu-22.04.2-live-server-amd64.iso
fi

if [ ! -d "bin" ]
then
  mkdir bin
  wget -O /tmp/rclone-v1.62.2-linux-amd64.zip https://github.com/rclone/rclone/releases/download/v1.62.2/rclone-v1.62.2-linux-amd64.zip
  mkdir -p /tmp/rclone
  unzip /tmp/rclone-v1.62.2-linux-amd64.zip -d /tmp/rclone
  cp /tmp/rclone/rclone-v1.62.2-linux-amd64/rclone bin/rclone
  rm -rf /tmp/rclone
  rm -f /tmp/rclone-v1.62.2-linux-amd64.zip
  wget -O bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc
  chmod +x bin/mc
fi

bin/mc --insecure alias set ferlab https://minio.ferlab.lan:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD
bin/mc --insecure mb --ignore-existing ferlab/pxe

mount -o loop image/ubuntu-22.04-server-amd64.iso /mnt

export RCLONE_CONFIG_S3_ACCESS_KEY_ID=$MINIO_ROOT_USER
export RCLONE_CONFIG_S3_SECRET_ACCESS_KEY=$MINIO_ROOT_PASSWORD
mkdir -p ~/.config/rclone
cp rclone.conf ~/.config/rclone/rclone.conf
bin/rclone --ca-cert /opt/shared/minio_ca.crt sync --links /mnt s3:pxe
