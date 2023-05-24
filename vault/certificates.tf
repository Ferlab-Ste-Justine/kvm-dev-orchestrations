module "vault_ca" {
  source      = "../ca"
  common_name = "vault"
}

resource "local_file" "vault_ca_cert" {
  content         = module.vault_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../shared/vault-ca.crt"
}

resource "local_file" "vault_ca_key" {
  content         = module.vault_ca.key
  file_permission = "0600"
  filename        = "${path.module}/../shared/vault-ca.key"
}


resource "tls_private_key" "vault_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "vault_request" {
  private_key_pem = tls_private_key.vault_key.private_key_pem

  subject {
    common_name = "vault-client-server"
  }

  dns_names = ["*.ferlab.lan"]
}

resource "tls_locally_signed_cert" "vault_certificate" {
  cert_request_pem      = tls_cert_request.vault_request.cert_request_pem
  ca_private_key_pem    = module.vault_ca.key
  ca_cert_pem           = module.vault_ca.certificate

  validity_period_hours = 100*365*24
  early_renewal_hours   = 365*24

  allowed_uses = [
    "client_auth",
    "server_auth",
  ]

  is_ca_certificate = false
}

resource "local_file" "vault_cert" {
  content         = tls_locally_signed_cert.vault_certificate.cert_pem
  file_permission = "0600"
  filename        = "${path.module}/../shared/vault.crt"
}

resource "local_file" "vault_key" {
  content         = tls_private_key.vault_key.private_key_pem
  file_permission = "0600"
  filename        = "${path.module}/../shared/vault.key"
}

resource "null_resource" "vault_pkcs12_from_pem" {
  triggers = {
    cert = sha256(local_file.vault_cert.content)
    key  = sha256(local_file.vault_key.content)
    pass = local.params.vault.pkcs12_password
  }

  provisioner "local-exec" {
    command = "openssl pkcs12 -export -in ${local_file.vault_cert.filename} -inkey ${local_file.vault_key.filename} -out ${path.module}/../shared/vault.p12 -passout pass:${local.params.vault.pkcs12_password}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm ${path.module}/../shared/vault.p12"
  }
}