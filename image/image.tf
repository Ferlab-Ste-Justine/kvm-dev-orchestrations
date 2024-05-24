resource "libvirt_volume" "ubuntu_jammy_2023_02_10" {
  name   = "ubuntu-jammy-2023-02-10"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/releases/jammy/release-20230210/ubuntu-22.04-server-cloudimg-amd64.img"
}

resource "libvirt_volume" "ubuntu_jammy_2023_05_18" {
  name   = "ubuntu-jammy-2023-05-18"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/releases/jammy/release-20230518/ubuntu-22.04-server-cloudimg-amd64.img"
}

resource "libvirt_volume" "ubuntu_jammy_2024_03_01" {
  name   = "ubuntu-jammy-2024-03-01"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/releases/jammy/release-20240301/ubuntu-22.04-server-cloudimg-amd64.img"
}
