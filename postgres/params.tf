locals {
  params = jsondecode(file("${path.module}/../shared/params.json"))
  cluster_state = yamldecode(file("${path.module}/cluster_state.yml"))
}