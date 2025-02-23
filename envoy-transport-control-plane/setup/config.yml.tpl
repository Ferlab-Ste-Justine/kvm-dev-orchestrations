etcd_client:
  prefix: /ferlab/envoy-transport-control-plane/
  endpoints:
%{ for endpoint in etcd_endpoints ~}
    - "${endpoint}"
%{ endfor ~}
  connection_timeout: "5m"
  request_timeout: "5m"
  retries: 20
  auth:
    ca_cert: "../../shared/etcd-ca.pem"
    password_auth: "./etcd_auth.yml"
server:
  port: 18000
  bind_ip: "0.0.0.0"
  max_connections: 1000
  keep_alive_time: "30s"
  keep_alive_timeout: "5s"
  keep_alive_min_time: "30s"
log_level: info
version_fallback: etcd