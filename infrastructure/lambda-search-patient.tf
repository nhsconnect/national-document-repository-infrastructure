module "search-patient-details-gateway" {
  # Gateway Variables
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  http_method         = "GET"
  authorization       = "CUSTOM"
  gateway_path        = "SearchPatient"
  authorizer_id       = aws_api_gateway_authorizer.repo_authoriser.id
  require_credentials = true
  origin              = "'https://${terraform.workspace}.${var.domain}'"

  # Lambda Variables
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  owner             = var.owner
  environment       = var.environment

  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
  ]
}

module "search_patient_alarm" {
  source               = "./modules/alarm"
  lambda_function_name = module.search-patient-details-lambda.function_name
  lambda_timeout       = module.search-patient-details-lambda.timeout
  lambda_name          = "search_patient_details_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.search_patient_alarm_topic.arn]
  ok_actions           = [module.search_patient_alarm_topic.arn]
  depends_on           = [module.search-patient-details-lambda, module.search_patient_alarm_topic]
}


module "search_patient_alarm_topic" {
  source         = "./modules/sns"
  topic_name     = "search_patient_details_alarms-topic"
  topic_protocol = "lambda"
  topic_endpoint = module.search-patient-details-lambda.endpoint
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

module "search-patient-details-lambda" {
  source  = "./modules/lambda"
  name    = "SearchPatientDetailsLambda"
  handler = "handlers.search_patient_details_handler.lambda_handler"
  iam_role_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy",
    aws_iam_policy.ssm_policy_pds.arn
  ]
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id = module.search-patient-details-gateway.gateway_resource_id
  http_method = "GET"
  lambda_environment_variables = {
    "PDS_FHIR_IS_STUBBED" = contains(["ndra", "ndrb", "ndrc", "ndrd", "ndr-test"], terraform.workspace)
  }
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.search-patient-details-gateway
  ]
}

resource "aws_iam_policy" "ssm_policy_pds" {
  name = "${terraform.workspace}_ssm_pds_parameters"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:PutParameter"
        ],
        Resource = [
          "arn:aws:ssm:*:*:parameter/*",
        ]
      }
    ]
  })
}