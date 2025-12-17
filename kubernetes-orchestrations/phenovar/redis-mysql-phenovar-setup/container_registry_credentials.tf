locals {
  container_registry_creds = yamldecode(file("${path.module}/../../../shared/container_registry_credentials.yml"))
}

resource "kubernetes_secret" "container_registry_credentials" {
  metadata {
    namespace = "phenovar"
    name      = "container-registry-credentials"
  }

  data = {
    ".dockerconfigjson" = templatefile(
      "${path.module}/templates/dockerconfigjson.tpl",
      {
        registry = "https://index.docker.io/v1/"
        username = local.container_registry_creds.username
        password = local.container_registry_creds.password
      }
    )
  }

  type = "kubernetes.io/dockerconfigjson"

  depends_on = [kubernetes_namespace.phenovar]
}