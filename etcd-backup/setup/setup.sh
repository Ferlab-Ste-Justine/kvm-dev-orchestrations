#!/bin/sh

mkdir -p ../work-env/snapshots;
(cd ../etcd-backup; go build; cp etcd-backup ../work-env/)
cp refresh.sh ../work-env/
cp run_docker.sh ../work-env/