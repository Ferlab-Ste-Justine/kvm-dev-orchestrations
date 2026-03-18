terraform {
  required_providers {
    minio = {
      source = "aminueza/minio"
      version = "3.8.0"
    }
  }
  required_version = ">= 1.0.0"
}