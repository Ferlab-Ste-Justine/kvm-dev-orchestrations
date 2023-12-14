resource "vault_mount" "minio_kes" {
  path = "minio-kes"
  type = "kv-v2"
}

resource "vault_policy" "minio_kes" {
  name   = vault_mount.minio_kes.path
  policy = <<EOT
path "minio-kes/data/*" {
     capabilities = [ "create", "read"]
}
path "minio-kes/metadata/*" {
     capabilities = [ "list", "delete"]
}
EOT
}

resource "vault_auth_backend" "approle" {
  type = "approle"
  path = "minio-kes"
}

resource "vault_approle_auth_backend_role" "minio_kes" {
    backend         = vault_auth_backend.approle.path
    role_name       = "minio-kes"
    token_policies  = [vault_policy.minio_kes.name]
}

resource "vault_approle_auth_backend_role_secret_id" "minio_kes" {
    backend   = vault_auth_backend.approle.path
    role_name = vault_approle_auth_backend_role.minio_kes.role_name
}

resource "local_file" "minio_kes_approle_id" {
  content         = vault_approle_auth_backend_role.minio_kes.role_id
  file_permission = "0600"
  filename        = "${path.module}/../shared/minio-kes-approle-id"
}

resource "local_file" "minio_kes_approle_secret" {
  content         = vault_approle_auth_backend_role_secret_id.minio_kes.secret_id
  file_permission = "0600"
  filename        = "${path.module}/../shared/minio-kes-approle-secret"
}