terraform {
  required_providers {
    etcd = {
      source = "Ferlab-Ste-Justine/etcd"
      version = "= 0.9.0"
    }
  }
  required_version = ">= 1.2.0"
}
