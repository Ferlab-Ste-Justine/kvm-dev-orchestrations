resource "tls_private_key" "admin_ssh" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "local_file" "admin_ssh" {
  content         = tls_private_key.admin_ssh.private_key_openssh
  file_permission = "0600"
  filename        = "${path.module}/../shared/starrocks_ssh_key"
}
