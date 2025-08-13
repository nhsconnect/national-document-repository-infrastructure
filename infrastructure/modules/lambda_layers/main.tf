locals {
  lambda_layer_aws_name = "${terraform.workspace}_${var.layer_name}_lambda_layer"
}

data "aws_caller_identity" "current" {}

data "archive_file" "lambda_layer_placeholder" {
  type        = "zip"
  source_file = "placeholder_lambda.py"
  output_path = "placeholder_lambda_payload.zip"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename                 = data.archive_file.lambda_layer_placeholder.output_path
  layer_name               = local.lambda_layer_aws_name
  compatible_runtimes      = ["python3.11"]
  compatible_architectures = ["x86_64"]

  lifecycle {
    ignore_changes = [
      # These are required as Lambdas are deployed via the CI/CD pipelines
      filename
    ]
  }
}
