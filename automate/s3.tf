resource "aws_iam_policy" "s3_access_policy" {
  name = "${var.namespace}_s3_access"
  path  = "/"
  description = "Policy to provide access to s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads",
          "s3:ListBucketVersions",
          "s3:ListObjectsV2"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${var.s3_backup_bucket}"
        ]
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:ListObjectsV2"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${var.s3_backup_bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "s3_policy_role" {
  name = "s3_access_attachment"
  roles = [data.terraform_remote_state.vpc.outputs.base_role_name]
  policy_arn = aws_iam_policy.s3_access_policy.arn
}
