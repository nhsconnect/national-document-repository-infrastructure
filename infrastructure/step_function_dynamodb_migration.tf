# --- Data and Variables Setup ---

data "aws_region" "current" {}

variable "project_name" {
  description = "Name of the project."
  type        = string
  default     = "DataMigration"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

variable "segment_generator_lambda_arn" {
  description = "ARN of the Lambda that generates the list of segments (PRMP-399)."
  type        = string
}

variable "aggregator_lambda_arn" {
  description = "ARN of the Lambda that aggregates the results."
  type        = string
}

variable "sfn_output_bucket_name" {
  description = "Name of the S3 bucket to store the Distributed Map results and final summary."
  type        = string
}

variable "max_concurrency" {
  description = "The maximum number of map iterations to run in parallel."
  type        = number
  default     = 100
}

# --- 1. CloudWatch Log Group for SFN Logs ---

resource "aws_cloudwatch_log_group" "sfn_log_group" {
  name              = "/aws/vendedlogs/states/${var.project_name}-${var.environment}-SFN"
  retention_in_days = 7
}

# --- 2. IAM Role for Step Functions ---

resource "aws_iam_role" "sfn_execution_role" {
  name = "${var.project_name}-${var.environment}-SFN-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "states.${data.aws_region.current.name}.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "sfn_policy" {
  name = "SFN-Execution-Policy"
  role = aws_iam_role.sfn_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        # Permissions to invoke the helper Lambdas (Generator and Aggregator)
        Action = ["lambda:InvokeFunction"],
        Effect = "Allow",
        Resource = [
          var.segment_generator_lambda_arn,
          var.aggregator_lambda_arn,
          # Must include the worker ARNs if they were known at deploy time, 
          # but since it's dynamic, we need to allow 'any' Lambda. 
          # A proper solution would narrow this scope if possible.
          "arn:aws:lambda:${data.aws_region.current.name}:*:function:*",
        ]
      },
      {
        # Permissions for the Distributed Map to read input and write output to S3
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${var.sfn_output_bucket_name}",
          "arn:aws:s3:::${var.sfn_output_bucket_name}/*"
        ]
      },
      {
        # Permissions for logging
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}


# --- 3. Step Function Definition (ASL) ---

locals {
  # Define the Amazon States Language (ASL) for the workflow
  sfn_definition = jsonencode({
    Comment = "Data Migration Workflow using Distributed Map and dynamic worker ARN.",
    StartAt = "GenerateSegments",
    States = {

      # 1. GenerateSegments: Calls Lambda (PRMP-399) to produce the segment list.
      "GenerateSegments" = {
        Type     = "Task",
        Resource = "arn:aws:states:::lambda:invoke",
        Parameters = {
          "FunctionName" = var.segment_generator_lambda_arn,
          "Payload.$"    = "$" # Pass entire input (including dryRun, workerLambdaArn)
        },
        # Assuming the generator Lambda returns a JSON with S3 location of the segment list:
        # e.g., {"s3Bucket": "my-bucket", "s3Key": "segments/run-123.json"}
        ResultPath = "$.SegmentsConfig",

        # Robust Retry/Catch block
        Retry = [{
          ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"],
          IntervalSeconds = 2,
          MaxAttempts     = 6,
          BackoffRate     = 2.0
        }],
        Catch = [{
          ErrorEquals = ["States.ALL"],
          Next        = "TerminalErrorHandler",
          ResultPath  = "$.Error"
        }],
        Next = "SegmentMigrationMap"
      },

      # 2. SegmentMigrationMap: The Distributed Map for parallel execution.
      "SegmentMigrationMap" = {
        Type           = "Map",
        MaxConcurrency = var.max_concurrency,
        Mode           = "Distributed",

        # ItemReader reads the segment list from S3, as output by the generator.
        ItemReader = {
          Resource = "arn:aws:states:::s3:getObject",
          Parameters = {
            "Bucket.$" = "$.SegmentsConfig.Payload.s3Bucket",
            "Key.$"    = "$.SegmentsConfig.Payload.s3Key"
          }
        },

        # ResultWriter stores the results of all map iterations in S3 for aggregation.
        ResultWriter = {
          Resource = "arn:aws:states:::s3:putObject",
          Parameters = {
            "Bucket"   = var.sfn_output_bucket_name,
            "Prefix.$" = "map-results/$$.Execution.Name"
          }
        },

        # The sub-workflow definition (Per segment worker)
        ItemProcessor = {
          ProcessorConfig = {
            Mode = "INLINE" # Executes the map tasks within the current execution
          },
          StartAt = "InvokeWorkerLambda",
          States = {
            "InvokeWorkerLambda" = {
              Type     = "Task",
              Resource = "arn:aws:states:::lambda:invoke",
              Parameters = {
                # DYNAMIC ARN: Fetches workerLambdaArn from the root execution input
                "FunctionName.$" = "$.workerLambdaArn",
                # Pass the segment details from the S3 list as payload
                "Payload.$" = "$$.Map.Item.Value"
              },
              # Robust Retry/Catch block (within the map iteration)
              Retry = [{
                ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"],
                IntervalSeconds = 2,
                MaxAttempts     = 6,
                BackoffRate     = 2.0
              }],
              Catch = [{
                ErrorEquals = ["States.ALL"],
                Next        = "TerminalErrorHandler",
                ResultPath  = "$.Error"
              }],
              End = true
            }
          }
        },
        Next = "AggregateResults"
      },

      # 3. AggregateResults: Summarize all segment results from S3.
      "AggregateResults" = {
        Type     = "Task",
        Resource = "arn:aws:states:::lambda:invoke",
        Parameters = {
          "FunctionName" = var.aggregator_lambda_arn,
          "Payload" = {
            # Pass the S3 location where the Map wrote its results
            "S3OutputLocation.$" = "$.ResultWriterDetails.OutputS3Location",
            "DryRun.$"           = "$.dryRun",
            "ExecutionName.$"    = "$$.Execution.Name"
          }
        },
        ResultPath = "$.Summary", # Store the final summary result

        # Robust Retry/Catch block
        Retry = [{
          ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"],
          IntervalSeconds = 2,
          MaxAttempts     = 6,
          BackoffRate     = 2.0
        }],
        Catch = [{
          ErrorEquals = ["States.ALL"],
          Next        = "TerminalErrorHandler",
          ResultPath  = "$.Error"
        }],
        End = true
      },

      # Terminal Handler: A common place for errors to land.
      "TerminalErrorHandler" = {
        Type  = "Fail",
        Cause = "Workflow failed due to an error in a step or segment processing.",
        Error = "MigrationFailure"
      }
    }
  })
}


# --- 4. Step Function Resource ---

resource "aws_sfn_state_machine" "data_migration_sfn" {
  name       = "${var.project_name}-${var.environment}-MigrationSFN"
  role_arn   = aws_iam_role.sfn_execution_role.arn
  definition = local.sfn_definition

  # Enable logging
  logging_configuration {
    level                  = "ALL"
    include_execution_data = true
    log_destination        = "f{cloudwatch_logs_log_group_arn = aws_cloudwatch_log_group.sfn_log_group.arn}"
  }
}
