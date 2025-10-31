resource "tls_private_key" "nfs_tunnel_client_key" {
  count = local.params.kubernetes.workers.nfs_tunnel ? 1 : 0
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "tls_cert_request" "nfs_tunnel_client_request" {
  count = local.params.kubernetes.workers.nfs_tunnel ? 1 : 0
  private_key_pem = tls_private_key.nfs_tunnel_client_key.0.private_key_pem
  subject {
    common_name  = "nfs-client"
    organization = "Ferlab"
  }
}

resource "tls_locally_signed_cert" "nfs_tunnel_client_certificate" {
  count = local.params.kubernetes.workers.nfs_tunnel ? 1 : 0
  cert_request_pem   = tls_cert_request.nfs_tunnel_client_request.0.cert_request_pem
  ca_private_key_pem = local.params.kubernetes.workers.nfs_tunnel ? file("${path.module}/../shared/nfs-ca.key") : ""
  ca_cert_pem        = local.params.kubernetes.workers.nfs_tunnel ? file("${path.module}/../shared/nfs-ca.crt") : ""

  validity_period_hours = 365 * 24
  early_renewal_hours = 14 * 24

  allowed_uses = [
    "client_auth"
  ]

  is_ca_certificate = false
}

resource "libvirt_volume" "kubernetes_workers" {
  count            = local.params.kubernetes.workers.count
  name             = "ferlab-kubernetes-worker-${count.index + 1}"
  pool             = "default"
  size             = 30 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format = "qcow2"
}

module "kubernetes_workers" {
  count  = local.params.kubernetes.workers.count
  source = "./terraform-libvirt-kubernetes-node"
  name = "ferlab-kubernetes-worker-${count.index + 1}"
  vcpus = local.params.kubernetes.workers.vcpus
  memory = local.params.kubernetes.workers.memory
  volume_id = libvirt_volume.kubernetes_workers[count.index].id
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = element(netaddr_address_ipv4.k8_workers.*.address, count.index)
    mac = element(netaddr_address_mac.k8_workers.*.address, count.index)
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  docker_registry_auth = local.docker_registry_auth
  nfs_tunnel = {
    enabled            = local.params.kubernetes.workers.nfs_tunnel
    server_domain      = "nfs.ferlab.lan"
    server_port        = 2050
    client_key         = local.params.kubernetes.workers.nfs_tunnel ? tls_private_key.nfs_tunnel_client_key.0.private_key_pem : ""
    client_certificate = local.params.kubernetes.workers.nfs_tunnel ? tls_locally_signed_cert.nfs_tunnel_client_certificate.0.cert_pem : ""
    ca_certificate     = local.params.kubernetes.workers.nfs_tunnel ? file("${path.module}/../shared/nfs-ca.crt") : ""
    nameserver_ips     = [data.netaddr_address_ipv4.coredns.0.address]
    max_connections    = 200
    idle_timeout       = "600s"
  }
  fluentbit = {
    enabled = local.params.logs_forwarding
    nfs_tunnel_client_tag = "kubernetes-worker-${count.index + 1}-nfs-tunnel"
    containerd_tag        = "kubernetes-worker-${count.index + 1}-containerd"
    kubelet_tag           = "kubernetes-worker-${count.index + 1}-kubelet"
    etcd_tag              = "kubernetes-worker-${count.index + 1}-etcd"
    node_exporter_tag     = "kubernetes-worker-${count.index + 1}-node-exporter"
    metrics = {
      enabled = true
      port    = 2020
    }
    forward = {
      domain = local.host_params.ip
      port = 4443
      hostname = "kubernetes-worker-${count.index + 1}"
      shared_key = local.params.logs_forwarding ? file("${path.module}/../shared/logs_shared_key") : ""
      ca_cert = local.params.logs_forwarding ? file("${path.module}/../shared/logs_ca.crt") : ""
    }
  }
}