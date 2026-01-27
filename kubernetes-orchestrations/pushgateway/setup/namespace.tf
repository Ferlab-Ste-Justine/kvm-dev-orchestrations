resource "kubernetes_namespace" "pushgateway" {
  metadata {
    name = "prometheus-pushgateway"
  }
}

