locals {
  kubeconfig = "${path.module}/../../shared/kubeconfig"
  context    = "kubernetes-admin-ferlab@ferlab"
}

provider "helm" {
  kubernetes = {
    config_path    = local.kubeconfig
    config_context = local.context
  }
}

provider "kubectl" {
  config_path    = local.kubeconfig
  config_context = local.context
}

provider "kubernetes" {
  config_path    = local.kubeconfig
  config_context = local.context
}
