locals {
  params = jsondecode(file("${path.module}/../../../shared/params.json"))
}

provider "kubernetes" {
  config_path  = "${path.module}/../../../shared/kubeconfig"
  config_context = "kubernetes-admin-ferlab@ferlab"
}