locals {
  params              = jsondecode(file("${path.module}/../shared/params.json"))
  domain              = "opensearch.ferlab.lan"
  resources_namespace = "ferlab"
}
