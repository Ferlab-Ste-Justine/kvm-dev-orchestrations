resource "random_password" "mysql_root_password" {
  length           = 16
  special          = false
}

resource "kubernetes_secret" "mysql_root_password" {
  metadata {
    name = "mysql-root-password"
    namespace = "phenovar"
  }

  data = {
    "MYSQL_ROOT_PASSWORD" = random_password.mysql_root_password.result
  }

  depends_on = [kubernetes_namespace.phenovar]
}