terraform {
  required_providers {
    etcd = {
      source = "Ferlab-Ste-Justine/etcd"
      version = ">=0.11.0"
    }
  }
  required_version = ">= 1.5.0"
}