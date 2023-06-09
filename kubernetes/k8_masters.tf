resource "libvirt_volume" "kubernetes_masters" {
  count            = local.params.kubernetes.masters.count
  name             = "ferlab-kubernetes-master-${count.index + 1}"
  pool             = "default"
  size             = 10 * 1024 * 1024 * 1024
  base_volume_pool = "default"
  base_volume_name = "ubuntu-jammy-2023-02-10"
  format = "qcow2"
}

module "kubernetes_masters" {
  count  = local.params.kubernetes.masters.count
  source = "./terraform-libvirt-kubernetes-node"
  name = "ferlab-kubernetes-master-${count.index + 1}"
  vcpus = local.params.kubernetes.masters.vcpus
  memory = local.params.kubernetes.masters.memory
  volume_id = libvirt_volume.kubernetes_masters[count.index].id
  libvirt_networks = [{
    network_name = "ferlab"
    network_id = ""
    ip = element(netaddr_address_ipv4.k8_masters.*.address, count.index)
    mac = element(netaddr_address_mac.k8_masters.*.address, count.index)
    gateway = local.params.network.gateway
    dns_servers = [data.netaddr_address_ipv4.coredns.0.address]
    prefix_length = split("/", local.params.network.addresses).1
  }]
  cloud_init_volume_pool = "default"
  ssh_admin_public_key = tls_private_key.admin_ssh.public_key_openssh
  admin_user_password = local.params.virsh_console_password
  fluentbit = {
    enabled = local.params.logs_forwarding
    nfs_tunnel_client_tag = ""
    containerd_tag        = "kubernetes-master-${count.index + 1}-containerd"
    kubelet_tag           = "kubernetes-master-${count.index + 1}-kubelet"
    etcd_tag              = "kubernetes-master-${count.index + 1}-etcd"
    node_exporter_tag     = "kubernetes-master-${count.index + 1}-node-exporter"
    metrics = {
      enabled = true
      port    = 2020
    }
    forward = {
      domain = local.host_params.ip
      port = 4443
      hostname = "kubernetes-master-${count.index + 1}"
      shared_key = local.params.logs_forwarding ? file("${path.module}/../shared/logs_shared_key") : ""
      ca_cert = local.params.logs_forwarding ? file("${path.module}/../shared/logs_ca.crt") : ""
    }
    etcd = {
      enabled = false
      key_prefix = ""
      endpoints = []
      ca_certificate = ""
      client = {
        certificate = ""
        key = ""
        username = ""
        password = ""
      }
    }
  }
}