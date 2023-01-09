resource "libvirt_pool" "default" {
  name = "default"
  type = "dir"
  path = "/var/lib/virt/pools/default"
}

resource "libvirt_volume" "ubuntu_focal_2022_12_13" {
  name   = "ubuntu-focal-2022-12-13"
  pool   = libvirt_pool.default.name
  source = "http://cloud-images.ubuntu.com/releases/focal/release-20221213/ubuntu-20.04-server-cloudimg-amd64.img"
}