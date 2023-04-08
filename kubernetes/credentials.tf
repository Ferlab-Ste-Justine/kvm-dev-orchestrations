resource "tls_private_key" "k8_ca" {
  algorithm   = "RSA"
  rsa_bits = 4096
}

resource "tls_private_key" "k8_etcd_ca" {
  algorithm   = "RSA"
  rsa_bits = 4096
}

resource "tls_private_key" "k8_front_proxy_ca" {
  algorithm   = "RSA"
  rsa_bits = 4096
}

resource "tls_private_key" "k8_client" {
  algorithm   = "RSA"
  rsa_bits = 4096
}

module "k8_certificates" {
  source = "./terraform-tls-kubernetes-certificates"
  ca_key = tls_private_key.k8_ca.private_key_pem
  etcd_ca_key = tls_private_key.k8_etcd_ca.private_key_pem
  front_proxy_ca_key = tls_private_key.k8_front_proxy_ca.private_key_pem
  client_key = tls_private_key.k8_client.private_key_pem
  client_certificate_lifespan = 3650
}

module "kubeconfig" {
  source = "./kubernetes-client-config"
  cluster_name = "ferlab"
  api_url = local.params.kubernetes.load_balancer.tunnel ? "https://tunnel.k8.ferlab.local:6443" : "https://k8.ferlab.local:6443"
  ca_certificate = module.k8_certificates.ca_certificate
  client_certificate = module.k8_certificates.client_certificate
  client_key = tls_private_key.k8_client.private_key_pem
}

resource "local_file" "kubeconfig" {
  content         = module.kubeconfig.config
  file_permission = "0600"
  filename        = "${path.module}/../shared/kubeconfig"
}
