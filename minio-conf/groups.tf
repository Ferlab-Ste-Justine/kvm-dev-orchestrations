resource "minio_iam_group" "developer" {
  name = "developer"
}

resource "minio_iam_group_policy_attachment" "developer" {
  group_name  = minio_iam_group.developer.name
  policy_name = minio_iam_policy.super_user.id
}

resource "minio_iam_group_policy_attachment" "developer2" {
  group_name  = minio_iam_group.developer.name
  policy_name = minio_iam_policy.super_user_2.id
}

resource "minio_iam_group_user_attachment" "developer" {
  group_name = minio_iam_group.developer.name
  user_name  = minio_iam_user.jerome.name
}

resource "minio_iam_group_user_attachment" "developer2" {
  group_name = minio_iam_group.developer.name
  user_name  = minio_iam_user.jerome2.name
}