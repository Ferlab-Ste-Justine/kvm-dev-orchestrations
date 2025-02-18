locals {
  params = jsondecode(file("${path.module}/../shared/params.json"))
  host_params = fileexists("${path.module}/../shared/host_params.json") ? jsondecode(file("${path.module}/../shared/host_params.json")) : {
    ip = ""
  }
  registry_credentials = fileexists("${path.module}/../shared/registry_credentials.yml") ? yamldecode(file("${path.module}/../shared/registry_credentials.yml")) : {
    credentials = []
  }
  docker_registry_auth = local.registry_credentials != { credentials = [] } ? {
    enabled  = true
    url      = local.registry_credentials.credentials[0].registry == "registry-1.docker.io" ? "https://index.docker.io/v1/" : local.registry_credentials.credentials[0].registry
    username = local.registry_credentials.credentials[0].username
    password = local.registry_credentials.credentials[0].password
  } : {
    enabled  = false
    url      = ""
    username = ""
    password = ""
  }
  custom_container_repos = {
    enabled     = true
    registry    = "docker.io/ferlabcrsj"
    image_names = {
      coredns                  = "k8-system_coredns.coredns"
      dnsautoscaler            = "k8-system_cpa.cluster-proportional-autoscaler"
      ingress_nginx_controller = "k8-system_ingress-nginx.controller"
      nodelocaldns             = "k8-system_dns.k8s-dns-node-cache"
      pause                    = "k8-system_pause"
    }
  }
}