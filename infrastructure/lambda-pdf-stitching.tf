module "pdf-stitching-lambda" {
  source         = "./modules/lambda"
  name           = "pdf-stitching-lambda"
  handler        = "handlers.pdf-stitching-lambda.lambda_handler"
  lambda_timeout = 900
  iam_role_policy_documents = [
    module.ndr-lloyd-george-store.s3_write_policy_document,
    module.ndr-lloyd-george-store.s3_read_policy_document,
    module.sqs-nrl-queue.sqs_write_policy_document,
    module.sqs-stitching-queue-deadletter.sqs_write_policy_document,
    module.sqs-stitching-queue.sqs_read_policy_document
  ]
  rest_api_id             = null
  api_execution_arn       = null
  is_invoked_from_gateway = false
}

resource "aws_lambda_event_source_mapping" "pdf-stitching-lambda" {
  event_source_arn = module.sqs-stitching-queue.arn
  function_name    = module.pdf-stitching-lambda.lambda_arn

  depends_on [
    module.pdf-stitching-lambda
    module.sqs-stitching
  ]
}

module "pdf-stitching-lambda-alarms" {
  source          = "modules/lambda_alarms
  lambda_function_name = module.pdf-stitching-lambda.function_name
  lambda_timeout       = module.pdf-stitching-lambda.timeout
  lambda_name          = "pdf-stitching-lambda"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.pdf-stitching-alarm-topic.arn]
  ok_actions           = [module.pdf-stitching-alarm-topic.arn]
  depends_on           = [module.pdf-stitching-lambda, module.pdf-stitching-alarm-topic]
}

module "pdf-stitching-alarm-topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  current_account_id    = data.aws_caller_identity.current.account_id
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

  depends_on = [module.pdf-stitching-lambda, module.sns_encryption_key]
}