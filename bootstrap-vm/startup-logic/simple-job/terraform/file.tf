resource "time_static" "time" {
  triggers = {
    touch = "test"
  }
}

resource "local_file" "time" {
  content         = time_static.time.unix
  file_permission = "0600"
  filename        = "/opt/terraform/timer-in-files/output/time"
}