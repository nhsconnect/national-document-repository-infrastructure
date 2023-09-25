module "fake_virus_scanned_event_lambda" {
  source  = "./modules/lambda"
  name    = "FakeVirusScanLambda"
  handler = "handlers.fake_virus_scan_handler.lambda_handler"
  iam_role_policies = [
    module.document_reference_dynamodb_table.dynamodb_policy,
    module.ndr-document-store.s3_object_access_policy,
    module.lloyd_george_reference_dynamodb_table.dynamodb_policy,
    module.ndr-lloyd-george-store.s3_object_access_policy,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  http_method       = "PATCH"
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    DOCUMENT_STORE_BUCKET_NAME   = "${terraform.workspace}-${var.docstore_bucket_name}"
    DOCUMENT_STORE_DYNAMODB_NAME = "${terraform.workspace}_DocumentReferenceMetadata"
    LLOYD_GEORGE_BUCKET_NAME     = "${terraform.workspace}-${var.lloyd_george_bucket_name}"
    LLOYD_GEORGE_DYNAMODB_NAME   = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.document_reference_dynamodb_table,
  ]
}

module "fake_virus_scan_alarm" {
  source               = "./modules/alarm"
  lambda_function_name = module.fake_virus_scanned_event_lambda.function_name
  lambda_timeout       = module.fake_virus_scanned_event_lambda.timeout
  lambda_name          = "fake_virus_scan_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.fake_virus_scan_topic.arn]
  ok_actions           = [module.fake_virus_scan_topic.arn]
  depends_on           = [module.fake_virus_scanned_event_lambda, module.fake_virus_scan_topic]
}


module "fake_virus_scan_topic" {
  source         = "./modules/sns"
  topic_name     = "fake-virus-scanner-alarms-topic"
  topic_protocol = "lambda"
  topic_endpoint = module.fake_virus_scanned_event_lambda.endpoint
  delivery_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudwatch.amazonaws.com"
        },
        "Action" : [
          "SNS:Publish",
        ],
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:cloudwatch:eu-west-2:${data.aws_caller_identity.current.account_id}:alarm:*"
          }
        }
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.ndr-document-store.s3_bucket_id

  lambda_function {
    lambda_function_arn = module.fake_virus_scanned_event_lambda.lambda_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3_permission_for_fake_virus_scanned_event]
}

resource "aws_lambda_permission" "s3_permission_for_fake_virus_scanned_event" {
  statement_id  = "AllowFakeScanExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.fake_virus_scanned_event_lambda.lambda_arn
  principal     = "s3.amazonaws.com"
  source_arn    = module.ndr-document-store.s3_bucket_arn
}