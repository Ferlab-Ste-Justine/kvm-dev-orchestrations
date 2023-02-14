locals {
  params = jsondecode(file("${path.module}/../shared/params.json"))
  custom_container_registry = {
    enabled = true
    path    = "docker.io/ferlabcrsj"
  }
  custom_container_repos = {
    enabled                    = true
    coredns                    = "k8-system_coredns.coredns"
    dnsautoscaler_without_arch = "k8-system_cpa.cluster-proportional-autoscaler"
    ingress_nginx_controller   = "k8-system_ingress-nginx.controller"
    nodelocaldns               = "k8-system_dns.k8s-dns-node-cache"
    pause                      = "k8-system_pause"
  }
}