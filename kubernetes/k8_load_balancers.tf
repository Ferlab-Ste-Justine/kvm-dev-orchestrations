resource "tls_private_key" "server_ssh" {
  count = local.params.kubernetes.load_balancer.tunnel ? 1 : 0
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "local_file" "tunnel_config" {
  count = local.params.kubernetes.load_balancer.tunnel ? 1 : 0
  content         = templatefile(
    "${path.module}/templates/tunnel_config.json.tpl",
    {
      ssh_fingerprint = tls_private_key.server_ssh.0.public_key_fingerprint_sha256
      ip = data.netaddr_address_ipv4.k8_lb.0.address
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/../shared/kubernetes_tunnel_config.json"
}

resource "local_file" "tunnel_secret" {
  count = local.params.kubernetes.load_balancer.tunnel ? 1 : 0
  content         = tls_private_key.admin_ssh.private_key_openssh
  file_permission = "0600"
  filename        = "${path.module}/../shared/kubernetes_auth_secret"
}

module "kubernetes_lb_configs" {
  source = "./terraform-etcd-envoy-transport-configuration"
  etcd_prefix = data.etcd_prefix_range_end.kubernetes_load_balancer.key
  node_id = "kubernetes-local"
  load_balancer = {
    services = [
      {
        name = "masters"
        listening_ip = "0.0.0.0"
        listening_port = 6443
        cluster_domain = "masters.k8.ferlab.local"
        cluster_port = 6443
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
          listener_certificate = ""
          listener_key = ""
        }
      },
      {
        name = "workers-ingress-http"
        listening_ip = "0.0.0.0"
        listening_port = 80
        cluster_domain = "workers.k8.ferlab.local"
        cluster_port = 30000
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
          listener_certificate = ""
          listener_key = ""
        }
      },
      {
        name = "workers-ingress-https"
        listening_ip = "0.0.0.0"
        listening_port = 443
        cluster_domain = "workers.k8.ferlab.local"
        cluster_port = 30001
        idle_timeout = "300s"
        max_connections = 1000
        access_log_format = "[%START_TIME%][Connection] %DOWNSTREAM_REMOTE_ADDRESS% to %UPSTREAM_HOST% (cluster %UPSTREAM_CLUSTER%). Error flags: %RESPONSE_FLAGS%\n"
        health_check = {
          timeout = "3s"
          interval = "3s"
          healthy_threshold = 1
          unhealthy_threshold = 2
        }
        tls_termination = {
          listener_certificate = ""
          listener_key = ""
        }
      }
    ]
    dns_servers = [{
      ip = data.netaddr_address_ipv4.coredns.0.address
      port = 53
    }]
  }
}

resource "libvirt_volume" "kubernetes_lb_1" {
  name             = "ferlab-kubernetes-lb-1"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format = "qcow2"
}

module "kubernetes_lb_1" {
  source = "./terraform-libvirt-transport-load-balancer"
  name = "ferlab-kubernetes-lb-1"
  vcpus = local.params.kubernetes.load_balancer.vcpus
  memory = local.params.kubernetes.load_balancer.memory
  volume_id = libvirt_volume.kubernetes_lb_1.id
  libvirt_network = {
    network_name = "ferlab"
    network_id = ""
    ip = data.netaddr_address_ipv4.k8_lb.0.address
    mac = data.netaddr_address_mac.k8_lb.0.address
  }
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  load_balancer = {
    cluster = "kubernetes-local"
    node_id = "kubernetes-local"
  }
  control_plane = {
    log_level        = "info"
    version_fallback = "etcd"
    server           = {
      port                = 18000
      max_connections     = 100
      keep_alive_time     = "30s"
      keep_alive_timeout  = "5s"
      keep_alive_min_time = "30s"
    }
    etcd        = {
      key_prefix         = data.etcd_prefix_range_end.kubernetes_load_balancer.key
      endpoints          = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
      connection_timeout = "30s"
      request_timeout    = "30s"
      retries            = 10
      ca_certificate     = file("${path.module}/../shared/etcd-ca.pem")
      client             = {
        certificate = ""
        key         = ""
        username    = etcd_user.kubernetes_load_balancer.username
        password    = etcd_user.kubernetes_load_balancer.password
      }
    }
  }
  ssh_tunnel = {
    enabled = local.params.kubernetes.load_balancer.tunnel
    ssh = {
      user = "tunnel"
      authorized_key = tls_private_key.admin_ssh.public_key_openssh
    }
  }
  ssh_host_key_rsa = {
    public = local.params.kubernetes.load_balancer.tunnel ? tls_private_key.server_ssh.0.public_key_openssh : ""
    private = local.params.kubernetes.load_balancer.tunnel ? tls_private_key.server_ssh.0.private_key_openssh : ""
  }
}