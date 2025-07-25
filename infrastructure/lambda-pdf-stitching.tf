module "pdf-stitching-lambda" {
  source         = "./modules/lambda"
  name           = "PdfStitchingLambda"
  handler        = "handlers.pdf_stitching_handler.lambda_handler"
  memory_size    = 1769
  lambda_timeout = 900
  iam_role_policy_documents = [
    module.sqs-nrl-queue.sqs_read_policy_document,
    module.sqs-nrl-queue.sqs_write_policy_document,
    module.sqs-stitching-queue.sqs_read_policy_document,
    module.sqs-stitching-queue.sqs_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    module.unstitched_lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
    module.unstitched_lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    module.ndr-lloyd-george-store.s3_read_policy_document,
    module.ndr-lloyd-george-store.s3_write_policy_document,
  ]
  rest_api_id             = null
  api_execution_arn       = null
  is_invoked_from_gateway = false
  lambda_environment_variables = {
    APIM_API_URL                          = data.aws_ssm_parameter.apim_url.value
    PDF_STITCHING_SQS_URL                 = module.sqs-stitching-queue.sqs_url
    NRL_SQS_URL                           = module.sqs-nrl-queue.sqs_url
    LLOYD_GEORGE_BUCKET_NAME              = "${terraform.workspace}-${var.lloyd_george_bucket_name}"
    LLOYD_GEORGE_DYNAMODB_NAME            = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    UNSTITCHED_LLOYD_GEORGE_DYNAMODB_NAME = "${terraform.workspace}_${var.unstitched_lloyd_george_dynamodb_table_name}"
    WORKSPACE                             = terraform.workspace
  }
}

resource "aws_lambda_event_source_mapping" "pdf-stitching-lambda" {
  event_source_arn = module.sqs-stitching-queue.endpoint
  function_name    = module.pdf-stitching-lambda.lambda_arn
}

module "pdf-stitching-lambda-alarms" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.pdf-stitching-lambda.function_name
  lambda_timeout       = module.pdf-stitching-lambda.timeout
  lambda_name          = "PdfStitchingLambda"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.pdf-stitching-alarm-topic.arn]
  ok_actions           = [module.pdf-stitching-alarm-topic.arn]
}

module "pdf-stitching-alarm-topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "pdf-stitching-alarm-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.pdf-stitching-lambda.lambda_arn
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
