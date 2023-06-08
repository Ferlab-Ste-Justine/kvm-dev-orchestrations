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

docker run -u $(id -u) -it --rm -e "SHARED_KEY=$(cat ../shared/logs_shared_key)" -v "$(pwd)/certs:/opt/certs" -v "$(pwd)/logs:/opt/logs" -v "$(pwd)/conf:/opt/conf" --network=host fluent/fluentd:v1.16-1 fluentd --config=/opt/conf/fluentd.conf