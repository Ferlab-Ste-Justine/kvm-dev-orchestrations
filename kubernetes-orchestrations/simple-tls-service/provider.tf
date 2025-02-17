provider "netaddr" {
  endpoints = join(",", [for etcd in local.params.etcd.addresses: "${etcd.ip}:2379"])
  ca_cert = "${path.module}/../../shared/etcd-ca.pem"
  username = "root"
  password = file("${path.module}/../../shared/etcd-root_password")
}

provider "kubectl" {
  config_path = "${path.module}/../../shared/kubeconfig"
  config_context = "kubernetes-admin-ferlab@ferlab"
}

provider "kubernetes" {
  config_path  = "${path.module}/../../shared/kubeconfig"
  config_context = "kubernetes-admin-ferlab@ferlab"
}
