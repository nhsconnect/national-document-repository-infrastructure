module "lambda-layer-core" {
  source     = "./modules/lambda_layers"
  account_id = data.aws_caller_identity.current.account_id
  layer_name = "core"
}

module "lambda-layer-data" {
  source     = "./modules/lambda_layers"
  account_id = data.aws_caller_identity.current.account_id
  layer_name = "data"
}

module "lambda-layer-alerting" {
  source     = "./modules/lambda_layers"
  account_id = data.aws_caller_identity.current.account_id
  layer_name = "alerting"
}

module "lambda-layer-reports" {
  source     = "./modules/lambda_layers"
  account_id = data.aws_caller_identity.current.account_id
  layer_name = "reports"
}

import {
  to = module.lambda-layer-core.aws_lambda_layer_version.lambda_layer
  id = "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:layer:${terraform.workspace}_core_lambda_layer:3"
}

import {
  to = module.lambda-layer-data.aws_lambda_layer_version.lambda_layer
  id = "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:layer:${terraform.workspace}_data_lambda_layer:3"
}

import {
  to = module.lambda-layer-alerting.aws_lambda_layer_version.lambda_layer
  id = "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:layer:${terraform.workspace}_alerting_lambda_layer:22"
}

import {
  to = module.lambda-layer-reports.aws_lambda_layer_version.lambda_layer
  id = "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:layer:${terraform.workspace}_reports_lambda_layer:1"
}
