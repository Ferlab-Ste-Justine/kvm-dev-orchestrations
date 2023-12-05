resource "kubectl_manifest" "job" {
    yaml_body = file("${path.module}/job.yml")
}
