locals {
  params = jsondecode(file("${path.module}/../shared/params.json"))
}