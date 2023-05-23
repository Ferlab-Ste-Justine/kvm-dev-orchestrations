data "etcd_prefix_range_end" "automation_server" {
    key = "/automation-server/"
}

resource "etcd_role" "automation_server" {
    name = "automation-server"

    permissions {
        permission = "readwrite"
        key = data.etcd_prefix_range_end.automation_server.key
        range_end = data.etcd_prefix_range_end.automation_server.range_end
    }
}

resource "random_password" "automation_server_etcd" {
  length           = 16
  special          = false
}

resource "etcd_user" "automation_server" {
    username = "automation-server"
    password = random_password.automation_server_etcd.result
    roles = [etcd_role.automation_server.name]
}

resource "etcd_range_scoped_state" "automation_server" {
    key = data.etcd_prefix_range_end.automation_server.key
    range_end = data.etcd_prefix_range_end.automation_server.range_end
    clear_on_creation = true
    clear_on_deletion = true
}