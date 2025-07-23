locals {
  to_shutdown = toset([
    for member in local.cluster_state.cluster: member.name if member.exists && !member.running
  ])
}


resource "null_resource" "postgres_shutdown" {
  for_each = local.to_shutdown

  provisioner "local-exec" {
    command = "virsh destroy ferlab-${each.value}"
  }

  depends_on = [
    module.postgres_1,
    module.postgres_2,
    module.postgres_3
  ]
}