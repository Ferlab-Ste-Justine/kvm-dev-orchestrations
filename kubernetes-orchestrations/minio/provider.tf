provider "kubernetes" {
  config_path  = "../../shared/kubeconfig"   # Path to your kubeconfig file
  config_context = "kubernetes-admin-ferlab@ferlab" # Set your kubeconfig context
}

provider "netaddr" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert = "${path.module}/../../shared/etcd-ca.pem"
  username = "root"
  password = file("${path.module}/../../shared/etcd-root_password")
}