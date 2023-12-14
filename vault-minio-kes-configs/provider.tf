provider "vault" {
  address      = "https://vault.ferlab.lan"
  token        = sensitive(chomp(file("${path.module}/../shared/vault-root-token")))
  ca_cert_file = "${path.module}/../shared/vault-ca.crt"
}