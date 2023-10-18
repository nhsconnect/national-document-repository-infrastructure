resource "aws_iam_policy" "s3_document_data_policy" {
  name = "${terraform.workspace}_${var.bucket_name}_get_document_data_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:CopyObject",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucketMultipartUploads",
          "s3:ListBucketVersions",
          "s3:ListBucket",
          "s3:DeleteObjectTagging",
          "s3:GetObjectRetention",
          "s3:DeleteObjectVersion",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectAttributes",
          "s3:RestoreObject",
          "s3:PutObjectVersionTagging",
          "s3:DeleteObjectVersionTagging",
          "s3:GetObjectVersionAttributes",
          "s3:GetObjectAcl",
          "s3:AbortMultipartUpload",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectTagging",
          "s3:PutObjectTagging",
          "s3:GetObjectVersion"
        ],
        "Resource" : ["${aws_s3_bucket.bucket.arn}/*", "${aws_s3_bucket.bucket.arn}/*"]
      }
    ]
  })
}

