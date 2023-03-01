module "kubernetes_installation" {
  source = "./kubernetes-installation"
  k8_cluster_name = "ferlab"
  k8_version = "v1.20.7"
  ingress_arguments = ["--enable-ssl-passthrough"]
  master_ips = [for elem in data.netaddr_address_ipv4.k8_masters: elem.address]
  worker_ips = [for elem in data.netaddr_address_ipv4.k8_workers: elem.address]
  bastion_external_ip = data.netaddr_address_ipv4.k8_bastion.0.address
  load_balancer_ips = [
    "k8.ferlab.local",
    "tunnel.k8.ferlab.local",
    data.netaddr_address_ipv4.k8_lb.0.address
  ]
  bastion_key_pair = {
    private_key = tls_private_key.admin_ssh.private_key_openssh
  }
  provisioning_path = "/home/ubuntu/ferlab-kubernetes/kubespray"
  artifacts_path = "/home/ubuntu/ferlab-kubernetes/kubespray-artifacts"
  cloud_init_sync_path = "/home/ubuntu/ferlab-kubernetes/cloud-init-sync"
  certificates_path = "/home/ubuntu/ferlab-kubernetes/certificates"
  bastion_dependent_ip = ""
  wait_on_ips = []
  ca_certificate = module.k8_certificates.ca_certificate
  ca_private_key = tls_private_key.k8_ca.private_key_pem
  etcd_ca_certificate = module.k8_certificates.etcd_ca_certificate
  etcd_ca_private_key = tls_private_key.k8_etcd_ca.private_key_pem
  front_proxy_ca_certificate = module.k8_certificates.front_proxy_ca_certificate
  front_proxy_ca_private_key = tls_private_key.k8_front_proxy_ca.private_key_pem
  depends_on = [
    module.kubernetes_masters,
    module.kubernetes_workers,
    module.kubernetes_lb_1,
    module.bastion,
  ]
  revision = "1"
}