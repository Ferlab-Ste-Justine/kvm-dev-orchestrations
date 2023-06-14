resource "etcd_synchronized_directory" "pxe_scripts" {
    directory = "${path.module}/pxe-scripts"
    key_prefix = data.etcd_prefix_range_end.pxe.key
    source = "directory"
    recurrence = "onchange"
}