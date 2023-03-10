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
      ssh_fingerprint = tls_private_key.server_ssh.0.public_key_fingerprint_md5
      ip = data.netaddr_address_ipv4.k8_lb.0.address
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/../shared/tunnel_config.json"
}

resource "local_file" "tunnel_secret" {
  count = local.params.kubernetes.load_balancer.tunnel ? 1 : 0
  content         = tls_private_key.admin_ssh.private_key_openssh
  file_permission = "0600"
  filename        = "${path.module}/../shared/auth_secret"
}

resource "libvirt_volume" "kubernetes_lb_1" {
  name             = "ferlab-kubernetes-lb-1"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-focal-2022-12-13"
  format = "qcow2"
}

module "kubernetes_lb_1" {
  source = "./kvm-kubernetes-load-balancer"
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
  k8_nameserver_ips = [data.netaddr_address_ipv4.coredns.0.address]
  k8_domain = "k8.ferlab.local"
  k8_masters_api_timeout = "30m"
  k8_workers_ingress_http_timeout = "60s"
  k8_workers_ingress_https_timeout = "5m"
  k8_workers_ingress_max_https_connections = 2000
  tunnel = {
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