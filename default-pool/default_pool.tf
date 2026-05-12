resource "libvirt_pool" "default" {
  name = "default"
  type = "dir"
  path = trimspace(file("${path.module}/../shared/default_pool_path"))
}
