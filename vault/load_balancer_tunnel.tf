resource "tls_private_key" "vault_server_ssh" {
  count     = local.params.vault.load_balancer.tunnel ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "vault_tunnel_config" {
  count   = local.params.vault.load_balancer.tunnel ? 1 : 0
  content = templatefile(
    "${path.module}/templates/tunnel_config.json.tpl",
    {
      ssh_fingerprint = tls_private_key.vault_server_ssh.0.public_key_fingerprint_sha256
      ip              = netaddr_address_ipv4.vault_lb_tunnel.0.address
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/../shared/vault_tunnel_config.json"
}

resource "local_file" "vault_tunnel_secret" {
  count           = local.params.vault.load_balancer.tunnel ? 1 : 0
  content         = tls_private_key.admin_ssh.private_key_openssh
  file_permission = "0600"
  filename        = "${path.module}/../shared/vault_auth_secret"
}

module "vault_lb_configs" {
  count         = local.params.vault.load_balancer.tunnel ? 1 : 0
  source        = "./terraform-etcd-envoy-transport-configuration"
  etcd_prefix   = data.etcd_prefix_range_end.vault_tunnel.0.key
  node_id       = "vault-local"
  load_balancer = {
    services = [
      {
        name              = "lbs"
        listening_ip      = "127.0.0.1"
        listening_port    = 443
        cluster_domain    = "vault.ferlab.lan"
        cluster_port      = 443
        idle_timeout      = "60s"
        max_connections   = 100
        access_log_format = "[%START_TIME%][Connection] %DOWNSTREAM_REMOTE_ADDRESS% to %UPSTREAM_HOST% (cluster %UPSTREAM_CLUSTER%). Error flags: %RESPONSE_FLAGS%\n"
        health_check      = {
          timeout             = "3s"
          interval            = "3s"
          healthy_threshold   = 1
          unhealthy_threshold = 2
        }
        tls_termination = {
          listener_certificate = ""
          listener_key         = ""
        }
      },
      {
        name              = "server-1"
        listening_ip      = "127.0.0.1"
        listening_port    = 4431
        cluster_domain    = "vault-server-1.ferlab.lan"
        cluster_port      = 8200
        idle_timeout      = "60s"
        max_connections   = 100
        access_log_format = "[%START_TIME%][Connection] %DOWNSTREAM_REMOTE_ADDRESS% to %UPSTREAM_HOST% (cluster %UPSTREAM_CLUSTER%). Error flags: %RESPONSE_FLAGS%\n"
        health_check      = {
          timeout             = "3s"
          interval            = "3s"
          healthy_threshold   = 1
          unhealthy_threshold = 2
        }
        tls_termination = {
          listener_certificate = ""
          listener_key         = ""
        }
      },
      {
        name              = "server-2"
        listening_ip      = "127.0.0.1"
        listening_port    = 4432
        cluster_domain    = "vault-server-2.ferlab.lan"
        cluster_port      = 8200
        idle_timeout      = "60s"
        max_connections   = 100
        access_log_format = "[%START_TIME%][Connection] %DOWNSTREAM_REMOTE_ADDRESS% to %UPSTREAM_HOST% (cluster %UPSTREAM_CLUSTER%). Error flags: %RESPONSE_FLAGS%\n"
        health_check      = {
          timeout             = "3s"
          interval            = "3s"
          healthy_threshold   = 1
          unhealthy_threshold = 2
        }
        tls_termination = {
          listener_certificate = ""
          listener_key         = ""
        }
      },
      {
        name              = "server-3"
        listening_ip      = "127.0.0.1"
        listening_port    = 4433
        cluster_domain    = "vault-server-3.ferlab.lan"
        cluster_port      = 8200
        idle_timeout      = "60s"
        max_connections   = 100
        access_log_format = "[%START_TIME%][Connection] %DOWNSTREAM_REMOTE_ADDRESS% to %UPSTREAM_HOST% (cluster %UPSTREAM_CLUSTER%). Error flags: %RESPONSE_FLAGS%\n"
        health_check      = {
          timeout             = "3s"
          interval            = "3s"
          healthy_threshold   = 1
          unhealthy_threshold = 2
        }
        tls_termination = {
          listener_certificate = ""
          listener_key         = ""
        }
      }
    ]
    dns_servers = [{
      ip   = data.netaddr_address_ipv4.coredns.0.address
      port = 53
    }]
  }
}

resource "libvirt_volume" "vault_lb_tunnel" {
  count            = local.params.vault.load_balancer.tunnel ? 1 : 0
  name             = "ferlab-vault-lb-tunnel"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format           = "qcow2"
}

module "vault_lb_tunnel" {
  count           = local.params.vault.load_balancer.tunnel ? 1 : 0
  source          = "./terraform-libvirt-transport-load-balancer"
  name            = "ferlab-vault-lb-tunnel"
  vcpus           = local.params.vault.load_balancer.vcpus
  memory          = local.params.vault.load_balancer.memory
  volume_id       = libvirt_volume.vault_lb_tunnel.0.id
  libvirt_networks = [{
    network_name      = "ferlab"
    network_id        = ""
    ip                = netaddr_address_ipv4.vault_lb_tunnel.0.address
    mac               = netaddr_address_mac.vault_lb_tunnel.0.address
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key   = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password    = local.params.virsh_console_password
  load_balancer          = {
    cluster                  = "vault-local"
    node_id                  = "vault-local"
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
    etcd = {
      key_prefix         = data.etcd_prefix_range_end.vault_tunnel.0.key
      endpoints          = [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"]
      connection_timeout = "30s"
      request_timeout    = "30s"
      retries            = 10
      ca_certificate     = file("${path.module}/../shared/etcd-ca.pem")
      client             = {
        certificate          = ""
        key                  = ""
        username             = etcd_user.vault_tunnel.0.username
        password             = etcd_user.vault_tunnel.0.password
      }
    }
  }
  ssh_tunnel = {
    enabled      = local.params.vault.load_balancer.tunnel
    ssh          = {
      user           = "tunnel"
      authorized_key = tls_private_key.admin_ssh.public_key_openssh
    }
  }
  ssh_host_key_rsa = {
    public             = local.params.vault.load_balancer.tunnel ? tls_private_key.vault_server_ssh.0.public_key_openssh : ""
    private            = local.params.vault.load_balancer.tunnel ? tls_private_key.vault_server_ssh.0.private_key_openssh : ""
  }
}