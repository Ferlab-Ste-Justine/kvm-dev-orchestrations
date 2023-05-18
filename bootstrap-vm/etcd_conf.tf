data "etcd_prefix_range_end" "boostrap" {
    key = "/bootstrap/"
}

resource "etcd_role" "boostrap" {
    name = "boostrap"

    permissions {
        permission = "readwrite"
        key = data.etcd_prefix_range_end.boostrap.key
        range_end = data.etcd_prefix_range_end.boostrap.range_end
    }
}

resource "random_password" "boostrap_etcd" {
  length           = 16
  special          = false
}

resource "etcd_user" "boostrap" {
    username = "boostrap"
    password = random_password.boostrap_etcd.result
    roles = [etcd_role.boostrap.name]
}

resource "etcd_range_scoped_state" "boostrap" {
    key = data.etcd_prefix_range_end.boostrap.key
    range_end = data.etcd_prefix_range_end.boostrap.range_end
    clear_on_creation = true
    clear_on_deletion = true
}