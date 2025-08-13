module "lambda-layer-core" {
  source     = "./modules/lambda_layers"
  layer_name = "core"
}

module "lambda-layer-data" {
  source     = "./modules/lambda_layers"
  layer_name = "data"
}

module "lambda-layer-alerting" {
  source     = "./modules/lambda_layers"
  layer_name = "alerting"
}

module "lambda-layer-reports" {
  source     = "./modules/lambda_layers"
  layer_name = "reports"
}
