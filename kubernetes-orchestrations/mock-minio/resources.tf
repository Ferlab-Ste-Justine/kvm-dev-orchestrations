resource "kubectl_manifest" "networking_deployment" {
    yaml_body = file("${path.module}/networking-deployment.yml")
}

resource "kubectl_manifest" "mock_minio_deployment" {
    yaml_body = file("${path.module}/mock-minio-deployment.yml")
}

resource "kubectl_manifest" "mock_minio_service" {
    yaml_body = file("${path.module}/mock-minio-service.yml")
}