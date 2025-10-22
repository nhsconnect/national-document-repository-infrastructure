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
  # Invoke both Lambdas
  statement {
    effect  = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = [
      module.migration-dynamodb-segment-lambda.lambda_arn,
      # module.dynamodb_migration_lambda.lambda_arn
    ]
  }

  # S3 bucket-level permissions
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      module.migration-dynamodb-segment-lambda.s3_bucket_arn
    ]
  }

  # S3 object-level permissions
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${module.migration-dynamodb-segment-lambda.s3_bucket_arn}/*"
    ]
  }

  # Distributed Map child executions
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

  # CloudWatch Logs delivery
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
            "tableArn.$"      = "$.tableArn",
            "executionId.$"   = "$$.Execution.Id"
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
        MaxConcurrency = 50,

        ItemReader = {
          Resource = "arn:aws:states:::s3:getObject",
          ReaderConfig = {
            InputType = "JSON"
          },
          Parameters = {
            "Bucket.$" = "$.SegmentSource.bucket",
            "Key.$"    = "$.SegmentSource.key"
          }
        },

        ItemSelector = {
          "segment.$"         = "$$.Map.Item.Value",
          "totalSegments.$"   = "$.totalSegments",
          "tableArn.$"        = "$.tableArn",
          "migrationScript.$" = "$.migrationScript",
          "run_migration.$"   = "$.run_migration",
          "execution_Id.$"    = "$$.Execution.Id"
        },

        ItemProcessor = {
          ProcessorConfig = {
            Mode          = "DISTRIBUTED",
            ExecutionType = "STANDARD"
          },
          StartAt = "Placeholder",
          States = {
            "Placeholder" = {
              Type    = "Pass",
              Comment = "TODO: Replace with Run DynamoDB Migration when module.dynamodb_migration_lambda exists",
              End     = true
            }
            # "Run DynamoDB Migration" = {
            #   Type     = "Task",
            #   Resource = "arn:aws:states:::lambda:invoke",
            #   Parameters = {
            #     FunctionName = module.dynamodb_migration_lambda.lambda_arn,
            #     "Payload" = {
            #       "segment.$"         = "$.segment",
            #       "totalSegments.$"   = "$.totalSegments",
            #       "tableArn.$"        = "$.tableArn",
            #       "migrationScript.$" = "$.migrationScript",
            #       "run_migration.$"   = "$.run_migration",
            #       "execution_Id.$"    = "$.execution_Id"
            #     }
            #   },
            #   ResultSelector = { "migrationResult.$" = "$.Payload" },
            #   ResultPath     = "$.MigrationResult",
            #   End            = true
            # }
          }
        },
        End = true
      }
    }
  })
}
