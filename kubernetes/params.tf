locals {
  params = jsondecode(file("${path.module}/../shared/params.json"))
  host_params = fileexists("${path.module}/../shared/host_params.json") ? jsondecode(file("${path.module}/../shared/host_params.json")) : {
    ip = ""
  }
  registry_credentials = fileexists("${path.module}/../shared/registry_credentials.yml") ? yamldecode(file("${path.module}/../shared/registry_credentials.yml")) : {
    credentials = []
  }
  custom_container_repos = {
    enabled     = true
    registry    = "docker.io/ferlabcrsj"
    image_names = {
      coredns                  = "k8-system_coredns.coredns"
      dnsautoscaler            = "k8-system_cpa.cluster-proportional-autoscaler-amd64"
      ingress_nginx_controller = "k8-system_ingress-nginx.controller"
      nodelocaldns             = "k8-system_dns.k8s-dns-node-cache"
      pause                    = "k8-system_pause"
    }
  }
}