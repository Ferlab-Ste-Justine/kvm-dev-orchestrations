resource "etcd_synchronized_directory" "alertmanager_confs" {
    directory = "${path.module}/alertmanager-configs"
    key_prefix = "/ferlab/alertmanager/"
    source = "directory"
    recurrence = "onchange"
}