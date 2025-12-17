resource "random_password" "flower_basic_auth_password" {
  length           = 16
  special          = false
}

resource "kubernetes_secret" "flower_basic_auth_password" {
  metadata {
    namespace = "phenovar"
    name      = "flower-basic-auth"
  }

  data = {
    auth = "phenovar:${bcrypt(random_password.flower_basic_auth_password.result)}"
  }

  depends_on = [kubernetes_namespace.phenovar]
}

resource "local_file" "flower_basic_auth_password" {
  content         = random_password.flower_basic_auth_password.result
  file_permission = "0600"
  filename        = "${path.module}/../../../shared/flower_basic_auth_password"
}