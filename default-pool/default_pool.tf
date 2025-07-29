resource "libvirt_pool" "default" {
  name = "default"
  type = "dir"
  path = file("${path.module}/../shared/default_pool_path")
}