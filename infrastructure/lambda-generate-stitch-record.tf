module "generate-lloyd-george-stitch-alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.generate-lloyd-george-stitch-lambda.function_name
  lambda_timeout       = module.generate-lloyd-george-stitch-lambda.timeout
  lambda_name          = "generate_lloyd_george_stitch_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.generate-lloyd-george-stitch-alarm-topic.arn]
  ok_actions           = [module.generate-lloyd-george-stitch-alarm-topic.arn]
  depends_on           = [module.generate-lloyd-george-stitch-lambda, module.generate-lloyd-george-stitch-alarm-topic]
}

module "generate-lloyd-george-stitch-alarm-topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "generate-lloyd-george-stitch-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.generate-lloyd-george-stitch-lambda.lambda_arn
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

  depends_on = [module.generate-lloyd-george-stitch-lambda, module.sns_encryption_key]
}

module "generate-lloyd-george-stitch-lambda" {
  source                   = "./modules/lambda"
  name                     = "GenerateLloydGeorgeStitch"
  handler                  = "handlers.generate_lloyd_george_stitch_handler.lambda_handler"
  lambda_timeout           = 900
  lambda_ephemeral_storage = 1024
  memory_size              = 1769
  iam_role_policy_documents = [
    module.ndr-document-store.s3_read_policy_document,
    module.ndr-document-store.s3_write_policy_document,
    module.ndr-lloyd-george-store.s3_read_policy_document,
    module.ndr-lloyd-george-store.s3_write_policy_document,
    module.ndr-app-config.app_config_policy,
    aws_iam_policy.dynamodb_stream_stitch_policy.policy,
    module.stitch_metadata_reference_dynamodb_table.dynamodb_read_policy_document,
    module.stitch_metadata_reference_dynamodb_table.dynamodb_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document
  ]
  kms_deletion_window = var.kms_deletion_window
  account_id          = data.aws_caller_identity.current.account_id
  rest_api_id         = null
  api_execution_arn   = null
  lambda_environment_variables = {
    APPCONFIG_APPLICATION         = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT         = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION       = module.ndr-app-config.app_config_configuration_profile_id
    SPLUNK_SQS_QUEUE_URL          = try(module.sqs-splunk-queue[0].sqs_url, null)
    STITCH_METADATA_DYNAMODB_NAME = "${terraform.workspace}_${var.stitch_metadata_dynamodb_table_name}"
    WORKSPACE                     = terraform.workspace
    PRESIGNED_ASSUME_ROLE         = aws_iam_role.stitch_presign_url_role.arn
    LLOYD_GEORGE_BUCKET_NAME      = "${terraform.workspace}-${var.lloyd_george_bucket_name}"
    LLOYD_GEORGE_DYNAMODB_NAME    = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
  }
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false

  depends_on = [
    aws_iam_policy.lambda_audit_splunk_sqs_queue_send_policy[0],
    module.ndr-app-config,
    module.ndr-document-store,
    module.ndr-lloyd-george-store,
    module.stitch_metadata_reference_dynamodb_table,
    module.lloyd_george_reference_dynamodb_table
  ]
}

resource "aws_iam_policy" "dynamodb_stream_stitch_policy" {
  name = "${terraform.workspace}_dynamodb_stream_to_stitch_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["dynamodb:GetRecords", "dynamodb:GetShardIterator", "dynamodb:DescribeStream", "dynamodb:ListStreams"]
        Effect   = "Allow"
        Resource = module.stitch_metadata_reference_dynamodb_table.dynamodb_stream_arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_generate_stitch_lambda" {
  count      = local.is_sandbox ? 0 : 1
  role       = module.generate-lloyd-george-stitch-lambda.lambda_execution_role_name
  policy_arn = try(aws_iam_policy.lambda_audit_splunk_sqs_queue_send_policy[0].arn, null)
}

resource "aws_lambda_event_source_mapping" "dynamodb_stream_stitch" {
  event_source_arn  = module.stitch_metadata_reference_dynamodb_table.dynamodb_stream_arn
  function_name     = module.generate-lloyd-george-stitch-lambda.lambda_arn
  batch_size        = 1
  starting_position = "TRIM_HORIZON"

  filter_criteria {
    filter {
      pattern = jsonencode({
        "eventName" : [
          "INSERT"
        ],
        "dynamodb" : {
          "NewImage" : {
            "JobStatus" : {
              "S" : [
                "Pending"
              ]
            }
          }
        }
      })
    }
  }
}
