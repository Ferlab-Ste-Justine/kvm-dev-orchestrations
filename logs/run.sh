rm -r logs
mkdir -p $(pwd)/logs/bootstrap-server

docker run -u $(id -u) -it --rm -e "SHARED_KEY=$(cat ../shared/logs_shared_key)" -v "$(pwd)/certs:/opt/certs" -v "$(pwd)/logs:/opt/logs" -v "$(pwd)/conf:/opt/conf" --network=host fluent/fluentd:v1.16-1 fluentd --config=/opt/conf/fluentd.conf