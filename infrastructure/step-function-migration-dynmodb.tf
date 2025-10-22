############################
# Variables
############################

variable "max_concurrency" {
  description = "Maximum number of concurrent Map iterations"
  type        = number
  default     = 50
}

variable "segment_bucket_kms_key_arn" {
  description = "Optional KMS key ARN if the S3 segment file is encrypted"
  type        = string
  default     = ""
}

variable "segment_bucket_name" {
  description = "S3 bucket name where segment files are stored"
  type        = string
}

############################
# Data Sources
############################

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

############################
# IAM Role for Step Functions
############################

data "aws_iam_policy_document" "sfn_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sfn_role" {
  name               = "${terraform.workspace}_migration_sfn_role"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume.json
}

data "aws_iam_policy_document" "sfn_permissions" {
  # Allow the Step Function to invoke both Lambdas
  statement {
    effect  = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = [
      module.migration-dynamodb-segment-lambda.lambda_arn,
      module.dynamodb_migration_lambda.lambda_arn
    ]
  }

  # Allow reading and writing segment files from/to specific S3 bucket
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.segment_bucket_name}",
      "arn:aws:s3:::${var.segment_bucket_name}/*"
    ]
  }

  # Required for Distributed Map child executions
  # Use a wildcard pattern based on workspace to avoid circular dependency
  statement {
    effect = "Allow"
    actions = [
      "states:StartExecution",
      "states:DescribeExecution",
      "states:StopExecution",
      "states:GetExecutionHistory",
      "states:ListExecutions",
      "states:DescribeMapRun",
      "states:ListMapRuns"
    ]
    resources = [
      "arn:aws:states:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stateMachine:${terraform.workspace}_migration_dynamodb_step_function",
      "arn:aws:states:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:execution:${terraform.workspace}_migration_dynamodb_step_function/*",
      "arn:aws:states:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:mapRun:${terraform.workspace}_migration_dynamodb_step_function/*"
    ]
  }

  # CloudWatch Logs permissions for Step Function execution history
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }

  # Optional — allow decrypting S3 object if it's KMS-encrypted
  dynamic "statement" {
    for_each = var.segment_bucket_kms_key_arn != "" ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey",
        "kms:DescribeKey"
      ]
      resources = [var.segment_bucket_kms_key_arn]
    }
  }
}

resource "aws_iam_role_policy" "sfn_policy" {
  name   = "${terraform.workspace}_migration_sfn_policy"
  role   = aws_iam_role.sfn_role.id
  policy = data.aws_iam_policy_document.sfn_permissions.json
}

############################
# Step Function Definition
############################

resource "aws_sfn_state_machine" "migration_dynamodb" {
  name     = "${terraform.workspace}_migration_dynamodb_step_function"
  role_arn = aws_iam_role.sfn_role.arn

  definition = jsonencode({
    StartAt = "Segment Creator",
    States = {
      "Segment Creator" = {
        Type     = "Task",
        Resource = "arn:aws:states:::lambda:invoke",
        Parameters = {
          "FunctionName" = module.migration-dynamodb-segment-lambda.lambda_arn,
          "Payload" = {
            "totalSegments.$" = "$.totalSegments",
            "table_arn.$"     = "$.tableArn",
            "execution_Id.$"  = "$$.Execution.Id"
          }
        },
        ResultSelector = {
          "bucket.$" = "$.Payload.bucket",
          "key.$"    = "$.Payload.key"
        },
        ResultPath = "$.SegmentSource",
        Next       = "Segment Map (Distributed)"
      },

      "Segment Map (Distributed)" = {
        Type           = "Map",
        MaxConcurrency = var.max_concurrency,

        # Distributed Map reads the JSON array directly from S3
        ItemReader = {
          Resource = "arn:aws:states:::s3:getObject",
          Parameters = {
            "Bucket.$" = "$.SegmentSource.bucket",
            "Key.$"    = "$.SegmentSource.key"
          }
        },

        # Input passed to each item
        ItemSelector = {
          "segment.$"         = "$$.Map.Item.Value",
          "totalSegments.$"   = "$.totalSegments",
          "tableArn.$"        = "$.tableArn",
          "migrationScript.$" = "$.migrationScript",
          "run_migration.$"   = "$.run_migration",
          "execution_Id.$"    = "$$.Execution.Id"
        },

        # Distributed worker: DynamoDBMigrationLambda
        ItemProcessor = {
          ProcessorConfig = {
            Mode          = "DISTRIBUTED",
            ExecutionType = "STANDARD"
          },
          StartAt = "Run DynamoDB Migration",
          States = {
            "Run DynamoDB Migration" = {
              Type     = "Task",
              Resource = "arn:aws:states:::lambda:invoke",
              Parameters = {
                "FunctionName" = module.dynamodb_migration_lambda.lambda_arn,
                "Payload" = {
                  "segment.$"         = "$.segment",
                  "totalSegments.$"   = "$.totalSegments",
                  "tableArn.$"        = "$.tableArn",
                  "migrationScript.$" = "$.migrationScript",
                  "run_migration.$"   = "$.run_migration",
                  "execution_Id.$"    = "$.execution_Id"
                }
              },
              ResultSelector = { "migrationResult.$" = "$.Payload" },
              ResultPath     = "$.MigrationResult",
              End            = true
            }
          }
        },

        End = true
      }
    }
  })
}
