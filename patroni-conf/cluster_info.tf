data "patroni_cluster" "cluster" {}

output "patroni_cluster" {
  value = data.patroni_cluster.cluster
}

data "patroni_dynamic_config" "config" {}

output "patroni_dynamic_config" {
  value = data.patroni_dynamic_config.config
}
