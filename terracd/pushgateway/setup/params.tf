locals {
  params = jsondecode(file("${path.module}/../../../shared/params.json"))
  host_params = fileexists("${path.module}/../../../shared/host_params.json") ? jsondecode(file("${path.module}/../../../shared/host_params.json")) : {
    ip = "127.0.0.10"
  }
}