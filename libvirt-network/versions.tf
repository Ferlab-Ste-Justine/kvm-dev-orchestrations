terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "= 0.7.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "= 2.5.1"
    }
  }
  required_version = ">= 1.0.0"
}
