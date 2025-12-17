resource "random_password" "mysql_phenovar_password" {
  length           = 16
  special          = false
}

resource "kubernetes_secret" "mysql_phenovar_password" {
  metadata {
    name = "mysql-phenovar-password"
    namespace = "phenovar"
  }

  data = {
    "SGMADMIN_PASSWORD" = random_password.mysql_phenovar_password.result
  }

  depends_on = [kubernetes_namespace.phenovar]
}