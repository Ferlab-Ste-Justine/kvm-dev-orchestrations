data "etcd_prefix_range_end" "ferio_keyspace" {
  key = "/ferlab/ferio/"
}

data "etcd_key_range" "ferio_keyspace" {
  key = data.etcd_prefix_range_end.ferio_keyspace.key
  range_end = data.etcd_prefix_range_end.ferio_keyspace.range_end
}

resource "local_file" "ferio_keyspace" {
  content         = templatefile(
    "${path.module}/templates/ferio_keyspace.md.tpl",
    {
      keyspace = data.etcd_key_range.ferio_keyspace.results
    }
  )
  file_permission = "0600"
  filename        = "${path.module}/../shared/ferio_keyspace.md"
}