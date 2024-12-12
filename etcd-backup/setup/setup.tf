resource "null_resource" "setup" {
  provisioner "local-exec" {
    command = "./setup.sh"
  }
}