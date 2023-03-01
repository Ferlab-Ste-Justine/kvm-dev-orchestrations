resource "kubectl_manifest" "volume" {
    yaml_body = file("${path.module}/volume.yml")
}

resource "kubectl_manifest" "volume_claim" {
    yaml_body = file("${path.module}/volume-claim.yml")

    depends_on = [kubectl_manifest.volume]
}

resource "kubectl_manifest" "deployment" {
    yaml_body = file("${path.module}/deployment.yml")

    depends_on = [kubectl_manifest.volume_claim]
}