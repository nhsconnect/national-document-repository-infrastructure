resource "aws_api_gateway_usage_plan" "apim" {
  name = "${terraform.workspace}_apim-usage-plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
    stage  = aws_api_gateway_stage.ndr_api.stage_name
  }
}

resource "aws_api_gateway_api_key" "apim" {
  name = "${terraform.workspace}_apim-api-key"
}

resource "aws_api_gateway_usage_plan_key" "apim" {
  key_id        = aws_api_gateway_api_key.apim.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.apim.id
}