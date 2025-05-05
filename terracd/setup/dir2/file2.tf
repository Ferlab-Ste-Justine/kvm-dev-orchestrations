resource "local_file" "bye" {
  content         = "bye5"
  file_permission = "0660"
  filename        = pathexpand("~/Projects/terracd-test/bye")
}

module "filemon" {
    source = "./file_module"
    name = "filemon"
    content = "filemon2"
}