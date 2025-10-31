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
      type = "AWS"
      identifiers = compact([
        module.create-doc-ref-lambda.lambda_execution_role_arn,
        local.is_production ? null : module.post-document-references-fhir-lambda.lambda_execution_role_arn
      ])
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
        "Resource" : ["${module.ndr-lloyd-george-store.bucket_arn}/*"]
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
  name = "${terraform.workspace}_get_document_only_policy_for_get_doc_lambda"

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
      identifiers = [module.get-doc-fhir-lambda.lambda_execution_role_arn]
    }
  }
}

resource "aws_iam_role" "get_fhir_doc_presign_url_role" {
  name               = "${terraform.workspace}_get_fhir_doc_presign_url_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_for_get_doc_ref_lambda.json
}


resource "aws_iam_role_policy_attachment" "get_doc_presign_url" {
  role       = aws_iam_role.get_fhir_doc_presign_url_role.name
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

data "aws_iam_policy_document" "lambda_toggle_bulk_upload_document" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:UpdateEventSourceMapping",
      "lambda:GetEventSourceMapping"
    ]

    resources = [
      aws_lambda_event_source_mapping.bulk_upload_lambda.arn
    ]
  }
}

resource "aws_iam_policy" "lambda_toggle_bulk_upload_policy" {
  name   = "${terraform.workspace}_lambda_toggle_bulk_upload_policy"
  policy = data.aws_iam_policy_document.lambda_toggle_bulk_upload_document.json
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

resource "aws_iam_role" "api_gateway_cloudwatch" {
  count = local.is_sandbox ? 0 : 1
  name  = "${terraform.workspace}_NdrAPIGatewayLogs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_logs" {
  count      = local.is_sandbox ? 0 : 1
  role       = aws_iam_role.api_gateway_cloudwatch[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}


resource "aws_api_gateway_account" "logging" {
  count               = local.is_sandbox ? 0 : 1
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch[0].arn
}

data "aws_iam_policy_document" "assume_role_policy_get_document_review_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [module.get_document_review_lambda.lambda_execution_role_arn]
    }
  }
}

resource "aws_iam_role" "get_document_review_presign" {
  name               = "${terraform.workspace}_stitch_presign_url_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_get_document_review_lambda.json
}

resource "aws_iam_role_policy_attachment" "get_document_review" {
  role       = aws_iam_role.get_document_review_presign.name
  policy_arn = aws_iam_policy.s3_document_data_policy_get_document_review_lambda.arn
}

resource "aws_iam_policy" "s3_document_data_policy_get_document_review_lambda" {
  name = "${terraform.workspace}_get_document_only_policy_for_get_document_review_lambda"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
        ],
        "Resource" : ["*"]
      }
    ]
  })
}
