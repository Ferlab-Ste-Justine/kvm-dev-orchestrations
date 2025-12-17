terraform {
  required_providers {
    minio = {
      source = "aminueza/minio"
      version = "3.5.4"
    }
  }
  required_version = ">= 1.0.0"
}