data "etcd_prefix_range_end" "test2" {
    key = "/test2"
}

data "etcd_prefix_range_end" "testmore2" {
    key = "/testmore2"
}

resource "etcd_role" "test" {
    name = "test"

    permissions {
        permission = "read"
        key = data.etcd_prefix_range_end.test2.key
        range_end = data.etcd_prefix_range_end.test2.range_end
    }
}

resource "etcd_role" "testmore" {
    name = "testmore"

    permissions {
        permission = "read"
        key = data.etcd_prefix_range_end.testmore2.key
        range_end = data.etcd_prefix_range_end.testmore2.range_end
    }
}

resource "etcd_role" "testmonitor" {
    name = "testmonitor"

    permissions {
        permission = "read"
        key = "\u0000"
        range_end = "\u0000"
    }
}

resource "etcd_user" "test" {
    username = "test"
    password = local.params.etcd.cert_auth ? null : "hello"
    roles = ["test", "testmore"]

    depends_on = [etcd_role.test, etcd_role.testmore]
}

resource "etcd_user" "test2" {
    username = "test2"
    password = local.params.etcd.cert_auth ? null : "hello"
    roles = []
}

resource "etcd_user" "testmonitor" {
    username = "testmonitor"
    password = local.params.etcd.cert_auth ? null : "hello"
    roles = ["testmonitor"]

    depends_on = [etcd_role.testmonitor]
}

resource "local_file" "testmonitor_cli" {
  filename = "${path.module}/get-keys-prefix.sh"
  file_permission = "0550"
  content  = "export ETCDCTL_ENDPOINTS=${join(",", [for etcd in local.params.etcd.addresses: "https://${etcd.ip}:2379"])}\netcdctl get --prefix \"$2\" --cacert=\"${path.module}/../shared/etcd-ca.pem\" --user=\"$1\" --password=\"hello\""
}