module "minio_audit_logs_ca" {
  source = "../../../ca-ecdsa-p256"
  common_name = "minio-audit-logs"
}

resource "tls_private_key" "minio_audit_logs_server" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "minio_audit_logs_server" {
  private_key_pem = tls_private_key.minio_audit_logs_server.private_key_pem
  dns_names = [
    "workers.k8.ferlab.lan"
  ]
  subject {
    common_name  = "workers.k8.ferlab.lan"
    organization = "Ferlab"
  }
}

resource "tls_locally_signed_cert" "minio_audit_logs_server" {
  cert_request_pem   = tls_cert_request.minio_audit_logs_server.cert_request_pem
  ca_private_key_pem = module.minio_audit_logs_ca.key
  ca_cert_pem        = module.minio_audit_logs_ca.certificate

  validity_period_hours = 87600
  early_renewal_hours   = 720

  allowed_uses = [
    "server_auth",
  ]
}

resource "kubernetes_secret" "minio_audit_logs_server_credentials" {
  metadata {
    name = "server-credentials"
    namespace = "minio-audit-logs"
  }

  data = {
    "ca.crt" = module.minio_audit_logs_ca.certificate
    "server.crt" = tls_locally_signed_cert.minio_audit_logs_server.cert_pem
    "server.key" = tls_private_key.minio_audit_logs_server.private_key_pem
  }

  depends_on = [kubernetes_namespace.minio_audit_logs]
}

resource "tls_private_key" "minio_audit_logs_client" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "minio_audit_logs_client" {
  private_key_pem = tls_private_key.minio_audit_logs_client.private_key_pem
  subject {
    common_name  = "minio-audit-logs-client"
    organization = "Ferlab"
  }
}

resource "tls_locally_signed_cert" "minio_audit_logs_client" {
  cert_request_pem   = tls_cert_request.minio_audit_logs_client.cert_request_pem
  ca_private_key_pem = module.minio_audit_logs_ca.key
  ca_cert_pem        = module.minio_audit_logs_ca.certificate

  validity_period_hours = 87600
  early_renewal_hours   = 720

  allowed_uses = [
    "client_auth",
    "digital_signature"
  ]
}

resource "local_file" "minio_audit_logs_ca_cert" {
  content         = module.minio_audit_logs_ca.certificate
  file_permission = "0600"
  filename        = "${path.module}/../../../shared/minio_audit_logs_ca.crt"
}

resource "local_file" "minio_audit_logs_client_cert" {
  content         = tls_locally_signed_cert.minio_audit_logs_client.cert_pem
  file_permission = "0600"
  filename        = "${path.module}/../../../shared/minio_audit_logs_client.crt"
}

resource "local_file" "minio_audit_logs_client_key" {
  content         = tls_private_key.minio_audit_logs_client.private_key_pem
  file_permission = "0600"
  filename        = "${path.module}/../../../shared/minio_audit_logs_client.key"
}