data "etcd_prefix_range_end" "kubernetes_load_balancer" {
  key = "/ferlab/k8-lbl/"
}

resource "etcd_role" "kubernetes_load_balancer" {
  name = "coredns"

  permissions {
    permission = "readwrite"
    key = data.etcd_prefix_range_end.kubernetes_load_balancer.key
    range_end = data.etcd_prefix_range_end.kubernetes_load_balancer.range_end
  }
}

resource "random_password" "kubernetes_load_balancer" {
  length           = 16
  special          = false
}

resource "etcd_user" "kubernetes_load_balancer" {
  username = "kubernetes-load-balancer"
  password = random_password.kubernetes_load_balancer.result
  roles = [etcd_role.kubernetes_load_balancer.name]
}