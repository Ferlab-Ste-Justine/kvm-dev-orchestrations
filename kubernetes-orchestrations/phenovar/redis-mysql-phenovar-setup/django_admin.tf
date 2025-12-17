resource "random_password" "phenovar_django_admin_password" {
  length           = 16
  special          = false
}

resource "kubernetes_secret" "phenovar_django_admin" {
  metadata {
    name = "phenovar-django-admin"
    namespace = "phenovar"
  }

  data = {
    DJANGO_SUPERUSER_USERNAME = "admin"
    DJANGO_SUPERUSER_PASSWORD = random_password.phenovar_django_admin_password.result
    DJANGO_SUPERUSER_EMAIL = "admin@example.com"
  }

  depends_on = [kubernetes_namespace.phenovar]
}