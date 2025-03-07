module "delete-document-object-alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.delete-document-object-lambda.function_name
  lambda_timeout       = module.delete-document-object-lambda.timeout
  lambda_name          = "delete_document_object_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.delete-document-object-alarm-topic.arn]
  ok_actions           = [module.delete-document-object-alarm-topic.arn]
}

module "delete-document-object-alarm-topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  current_account_id    = data.aws_caller_identity.current.account_id
  topic_name            = "delete-document-object-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.delete-document-object-lambda.lambda_arn
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

module "delete-document-object-lambda" {
  source         = "./modules/lambda"
  name           = "DeleteDocumentObjectS3"
  handler        = "handlers.delete_document_object_handler.lambda_handler"
  lambda_timeout = 900
  iam_role_policy_documents = [
    module.document_reference_dynamodb_table.dynamodb_read_policy_document,
    module.document_reference_dynamodb_table.dynamodb_write_policy_document,
    module.ndr-document-store.s3_read_policy_document,
    module.ndr-document-store.s3_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
    module.ndr-lloyd-george-store.s3_read_policy_document,
    module.ndr-lloyd-george-store.s3_write_policy_document,
    module.ndr-app-config.app_config_policy,
    aws_iam_policy.dynamodb_stream_delete_object_policy.policy
  ]
  rest_api_id       = null
  api_execution_arn = null
  lambda_environment_variables = {
    APPCONFIG_APPLICATION   = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT   = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE               = terraform.workspace
  }
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false
}

resource "aws_iam_policy" "dynamodb_stream_delete_object_policy" {
  name = "${terraform.workspace}_dynamodb_stream_to_delete_records_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["dynamodb:GetRecords", "dynamodb:GetShardIterator", "dynamodb:DescribeStream", "dynamodb:ListStreams"]
        Effect = "Allow"
        Resource = [
          module.lloyd_george_reference_dynamodb_table.dynamodb_stream_arn,
          module.document_reference_dynamodb_table.dynamodb_stream_arn,
          module.unstitched_lloyd_george_reference_dynamodb_table.dynamodb_stream_arn
        ]
      },
    ]
  })
}

resource "aws_lambda_event_source_mapping" "lloyd_george_dynamodb_stream" {
  event_source_arn  = module.lloyd_george_reference_dynamodb_table.dynamodb_stream_arn
  function_name     = module.delete-document-object-lambda.lambda_arn
  batch_size        = 1
  starting_position = "LATEST"

  filter_criteria {
    filter {
      pattern = jsonencode({
        "eventName" : [
          "REMOVE"
        ],
        userIdentity = {
          type        = ["Service"],
          principalId = ["dynamodb.amazonaws.com"]
        }
      })
    }
  }
}

resource "aws_lambda_event_source_mapping" "unstitched_lloyd_george_dynamodb_stream" {
  event_source_arn  = module.unstitched_lloyd_george_reference_dynamodb_table.dynamodb_stream_arn
  function_name     = module.delete-document-object-lambda.lambda_arn
  batch_size        = 1
  starting_position = "LATEST"

  filter_criteria {
    filter {
      pattern = jsonencode({
        "eventName" : [
          "REMOVE"
        ],
        userIdentity = {
          type        = ["Service"],
          principalId = ["dynamodb.amazonaws.com"]
        }
      })
    }
  }
}

resource "aws_lambda_event_source_mapping" "document_reference_dynamodb_stream" {
  event_source_arn  = module.document_reference_dynamodb_table.dynamodb_stream_arn
  function_name     = module.delete-document-object-lambda.lambda_arn
  batch_size        = 1
  starting_position = "LATEST"

  filter_criteria {
    filter {
      pattern = jsonencode({
        "eventName" : [
          "REMOVE"
        ],
        userIdentity = {
          type        = ["Service"],
          principalId = ["dynamodb.amazonaws.com"]
        }
      })
    }
  }
}