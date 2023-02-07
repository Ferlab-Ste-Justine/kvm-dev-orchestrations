data "etcd_prefix_range_end" "patroni" {
    key = "/patroni/"
}

resource "etcd_role" "patroni" {
    name = "patroni"

    permissions {
        permission = "readwrite"
        key = data.etcd_prefix_range_end.patroni.key
        range_end = data.etcd_prefix_range_end.patroni.range_end
    }
}

resource "random_password" "patroni_etcd_password" {
  length           = 16
  special          = false
}

resource "etcd_user" "patroni" {
    username = "patroni"
    password = random_password.patroni_etcd_password.result
    roles = [etcd_role.patroni.name]
}