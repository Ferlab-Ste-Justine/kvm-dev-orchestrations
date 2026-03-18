resource "minio_iam_policy" "super_user" {
  name = "super-user"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*",
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["admin:*"]
        Resource = ["**"]
      }
    ]
  })
}

resource "minio_iam_policy" "super_user_2" {
  name = "super-user-2"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*",
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["admin:*"]
        Resource = ["**"]
      }
    ]
  })
}

resource "minio_iam_policy" "super_user_3" {
  name = "super-user-3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*",
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["admin:*"]
        Resource = ["**"]
      }
    ]
  })
}

resource "minio_iam_user_policy_attachment" "super_user" {
  user_name   = minio_iam_user.jerome.id
  policy_name = minio_iam_policy.super_user.id
}

resource "minio_iam_user_policy_attachment" "super_user_2" {
  user_name   = minio_iam_user.jerome.id
  policy_name = minio_iam_policy.super_user_2.id
}

resource "minio_iam_user_policy_attachment" "super_user_3" {
  user_name   = minio_iam_user.jerome.id
  policy_name = minio_iam_policy.super_user_3.id
}