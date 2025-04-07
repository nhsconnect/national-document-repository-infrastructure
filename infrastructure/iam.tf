resource "aws_iam_policy" "s3_document_data_policy_put_only" {
  name = "${terraform.workspace}_put_document_only_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
        ],
        "Resource" : ["${module.ndr-bulk-staging-store.bucket_arn}/*", "${module.ndr-document-store.bucket_arn}/*"]
      }
    ]
  })
}

data "aws_iam_policy_document" "assume_role_policy_for_create_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [module.create-doc-ref-lambda.lambda_execution_role_arn]
    }
  }
}

resource "aws_iam_role" "create_post_presign_url_role" {
  name               = "${terraform.workspace}_create_post_presign_url_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_for_create_lambda.json
}

resource "aws_iam_role_policy_attachment" "create_post_presign_url" {
  role       = aws_iam_role.create_post_presign_url_role.name
  policy_arn = aws_iam_policy.s3_document_data_policy_put_only.arn
}

resource "aws_iam_policy" "s3_document_data_policy_for_stitch_lambda" {
  name = "${terraform.workspace}_get_document_only_policy_for_stitch_lambda"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "S3:ListBucket",
        ],
        "Resource" : ["${module.ndr-lloyd-george-store.bucket_arn}/combined_files/*"]
      }
    ]
  })
}

data "aws_iam_policy_document" "assume_role_policy_for_stitch_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [module.lloyd-george-stitch-lambda.lambda_execution_role_arn]
    }
  }
}

resource "aws_iam_role" "stitch_presign_url_role" {
  name               = "${terraform.workspace}_stitch_presign_url_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_for_stitch_lambda.json
}

resource "aws_iam_role_policy_attachment" "stitch_presign_url" {
  role       = aws_iam_role.stitch_presign_url_role.name
  policy_arn = aws_iam_policy.s3_document_data_policy_for_stitch_lambda.arn
}

resource "aws_iam_policy" "s3_document_data_policy_for_manifest_lambda" {
  name = "${terraform.workspace}_get_document_only_policy_for_manifest_lambda"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
        ],
        "Resource" : ["${module.ndr-zip-request-store.bucket_arn}/*"]
      }
    ]
  })
}

data "aws_iam_policy_document" "assume_role_policy_for_manifest_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [module.document-manifest-job-lambda.lambda_execution_role_arn]
    }
  }
}

resource "aws_iam_role" "manifest_presign_url_role" {
  name               = "${terraform.workspace}_manifest_presign_url_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_for_manifest_lambda.json
}

resource "aws_iam_role_policy_attachment" "manifest_presign_url" {
  role       = aws_iam_role.manifest_presign_url_role.name
  policy_arn = aws_iam_policy.s3_document_data_policy_for_manifest_lambda.arn
}


resource "aws_iam_policy" "s3_document_data_policy_for_get_doc_ref_lambda" {
  name = "${terraform.workspace}_get_document_only_policy_for_nrl_get_doc_lambda"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
        ],
        "Resource" : ["${module.ndr-lloyd-george-store.bucket_arn}/*"]
      }
    ]
  })
}

data "aws_iam_policy_document" "assume_role_policy_for_get_doc_ref_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [module.get-doc-nrl-lambda.lambda_execution_role_arn]
    }
  }
}

resource "aws_iam_role" "nrl_get_doc_presign_url_role" {
  name               = "${terraform.workspace}_nrl_get_doc_presign_url_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_for_get_doc_ref_lambda.json
}

resource "aws_iam_role_policy_attachment" "nrl_get_doc_presign_url" {
  role       = aws_iam_role.nrl_get_doc_presign_url_role.name
  policy_arn = aws_iam_policy.s3_document_data_policy_for_get_doc_ref_lambda.arn
}

resource "aws_iam_policy" "s3_document_data_policy_for_ods_report_lambda" {
  name = "${terraform.workspace}_get_document_only_policy_for_ods_report_lambda"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
        ],
        "Resource" : ["${module.statistical-reports-store.bucket_arn}/ods-reports/*"]
      }
    ]
  })
}

data "aws_iam_policy_document" "assume_role_policy_for_ods_report_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [module.get-report-by-ods-lambda.lambda_execution_role_arn]
    }
  }
}

resource "aws_iam_role" "ods_report_presign_url_role" {
  name               = "${terraform.workspace}_ods_report_presign_url_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_for_ods_report_lambda.json
}

resource "aws_iam_role_policy_attachment" "ods_report_presign_url" {
  role       = aws_iam_role.ods_report_presign_url_role.name
  policy_arn = aws_iam_policy.s3_document_data_policy_for_ods_report_lambda.arn
}

resource "aws_iam_policy" "ssm_policy" {
  name = "${terraform.workspace}_ssm_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParametersByPath"
        ],
        Resource = [
          "arn:aws:ssm:*:*:parameter/*",
        ]
      }
    ]
  })
}