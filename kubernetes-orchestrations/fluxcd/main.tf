module "fluxcd_installation" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-kubectl-fluxcd-installation.git?ref=v4"

  chart_version    = "2.18.3"
  fluxcd_namespace = "fluxcd-system"
}

module "fluxcd_bootstrap" {
  source = "git::https://github.com/Ferlab-Ste-Justine/terraform-kubernetes-fluxcd-bootstrap.git?ref=v0.3.0"

  fluxcd_namespace = {
    name   = "fluxcd-system"
    labels = {}
  }

  git_identity    = file("${path.module}/../../shared/flux_git_identity")
  git_known_hosts = file("${path.module}/../../shared/flux_git_known_hosts")

  repo_url    = "ssh://git@github.com/Ferlab-Ste-Justine/kvm-dev-orchestrations.git"
  repo_branch = "main"
  repo_path   = "./kubernetes-orchestrations"

  depends_on = [module.fluxcd_installation]
}
