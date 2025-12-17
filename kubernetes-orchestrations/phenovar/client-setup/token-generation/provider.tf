provider "kubernetes" {
  config_path  = "${path.module}/../../../../shared/kubeconfig"
  config_context = "kubernetes-admin-ferlab@ferlab"
}