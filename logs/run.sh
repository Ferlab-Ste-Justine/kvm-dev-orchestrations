rm -r logs
mkdir -p $(pwd)/logs/automation-server
mkdir -p $(pwd)/logs/etcd-cluster/server-1
mkdir -p $(pwd)/logs/etcd-cluster/server-2
mkdir -p $(pwd)/logs/etcd-cluster/server-3
mkdir -p $(pwd)/logs/coredns/server-1
mkdir -p $(pwd)/logs/prometheus/server-1
mkdir -p $(pwd)/logs/nfs-server
mkdir -p $(pwd)/logs/kubernetes/load-balancer-1
mkdir -p $(pwd)/logs/kubernetes/master-1
mkdir -p $(pwd)/logs/kubernetes/master-2
mkdir -p $(pwd)/logs/kubernetes/master-3
mkdir -p $(pwd)/logs/kubernetes/worker-1
mkdir -p $(pwd)/logs/kubernetes/worker-2
mkdir -p $(pwd)/logs/kubernetes/worker-3
mkdir -p $(pwd)/logs/minio/server-1
mkdir -p $(pwd)/logs/minio/server-2
mkdir -p $(pwd)/logs/minio/server-3
mkdir -p $(pwd)/logs/minio/server-4
mkdir -p $(pwd)/logs/minio/server-5
mkdir -p $(pwd)/logs/minio/server-6
mkdir -p $(pwd)/logs/minio/server-7
mkdir -p $(pwd)/logs/minio/server-8
mkdir -p $(pwd)/logs/alertmanager/server-1
mkdir -p $(pwd)/logs/alertmanager/server-2
mkdir -p $(pwd)/logs/vault/tunnel
mkdir -p $(pwd)/logs/starrocks/fe-1
mkdir -p $(pwd)/logs/starrocks/fe-2
mkdir -p $(pwd)/logs/starrocks/fe-3
mkdir -p $(pwd)/logs/starrocks/be-1
mkdir -p $(pwd)/logs/starrocks/be-2
mkdir -p $(pwd)/logs/starrocks/be-3

terraform init && terraform apply -auto-approve

docker run -u $(id -u) -it --rm -e "SHARED_KEY=$(cat ../shared/logs_shared_key)" -v "$(pwd)/certs:/opt/certs" -v "$(pwd)/logs:/opt/logs" -v "$(pwd)/conf:/opt/conf" --network=host fluent/fluentd:v1.16-1 fluentd --config=/opt/conf/fluentd.conf