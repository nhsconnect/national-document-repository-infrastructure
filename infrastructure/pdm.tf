resource "aws_api_gateway_usage_plan" "pdm" {
  name = "${terraform.workspace}_pdm-usage-plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
    stage  = aws_api_gateway_stage.ndr_api.stage_name
  }
}

resource "aws_api_gateway_api_key" "pdm" {
  name = "${terraform.workspace}_pdm-api-key"
}

resource "aws_api_gateway_usage_plan_key" "pdm" {
  key_id        = aws_api_gateway_api_key.pdm.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.pdm.id
}