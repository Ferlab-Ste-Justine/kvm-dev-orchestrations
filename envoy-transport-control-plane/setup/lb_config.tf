module "lb_configs" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-etcd-envoy-transport-configuration.git?ref=v0.6.0"
  etcd_prefix = data.etcd_prefix_range_end.envoy_transport_control_plane.key
  node_id = "envoy"
  load_balancer = {
    services = [
      {
        name = "simple-service"
        listening_ip = "0.0.0.0"
        listening_port = 8443
        cluster_domain = "simple-service.k8.ferlab.lan"
        cluster_port = 443
        idle_timeout = "60s"
        max_connections = 100
        access_log_format = "[%START_TIME%][Connection] %DOWNSTREAM_REMOTE_ADDRESS% to %UPSTREAM_HOST% (cluster %UPSTREAM_CLUSTER%). Error flags: %RESPONSE_FLAGS%\n"
        health_check = {
          timeout = "3s"
          interval = "3s"
          healthy_threshold = 1
          unhealthy_threshold = 2
        }
        tls_termination = {
          listener_certificate = "./server.crt"
          listener_key = "./server.key"
          cluster_client_certificate = "../../shared/simple_service_client.crt"
          cluster_client_key = "../../shared/simple_service_client.key"
          cluster_ca_certificate = "../../shared/simple_service_ca.crt"
        }
      }
    ]
    dns_servers = [{
      ip = data.netaddr_address_ipv4.coredns.0.address
      port = 53
    }]
  }
}