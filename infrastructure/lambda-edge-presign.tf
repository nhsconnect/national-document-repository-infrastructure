module "edge_presign_alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.edge-presign-lambda.function_name
  lambda_timeout       = module.edge-presign-lambda.timeout
  lambda_name          = "edge_presign_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.edge_presign_alarm_topic.arn]
  ok_actions           = [module.edge_presign_alarm_topic.arn]
  depends_on           = [module.edge-presign-lambda, module.edge_presign_alarm_topic]
}


module "edge_presign_alarm_topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  current_account_id    = data.aws_caller_identity.current.account_id
  topic_name            = "edge_presign-alarms-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.edge-presign-lambda.lambda_arn
  depends_on            = [module.sns_encryption_key]
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

module "edge-presign-lambda" {
  source         = "./modules/lambda_edge"
  lambda_timeout = 5
  name           = "EdgePresignLambda"
  handler        = "handlers.edge_presign_handler.lambda_handler"
  iam_role_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    aws_iam_policy.ssm_policy_oidc.arn,
    module.auth_state_dynamodb_table.dynamodb_policy,
    module.ndr-app-config.app_config_policy_arn
  ]
  providers = {
    aws = aws.us_east_1
  }
  current_account_id = data.aws_caller_identity.current.account_id
  bucket_name        = module.ndr-lloyd-george-store.bucket_id
  table_name         = module.cloudfront_edge_dynamodb_table.table_name
}
