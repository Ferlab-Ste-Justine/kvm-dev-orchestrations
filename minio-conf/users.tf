resource "minio_iam_user" "jerome" {
  name   = "jerome"
  secret = "jerome123456"
}

resource "minio_iam_user" "jerome2" {
  name   = "jerome2"
  secret = "jerome123456"
}