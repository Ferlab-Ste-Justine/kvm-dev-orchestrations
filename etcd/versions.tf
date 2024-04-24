terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "= 0.7.1"
    }
    healthcheck = {
      source = "Ferlab-Ste-Justine/healthcheck"
      version = "= 0.2.0"
    }
  }
  required_version = ">= 1.0.0"
}
