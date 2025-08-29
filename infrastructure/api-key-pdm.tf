resource "aws_api_gateway_usage_plan" "api_key_pdm" {
  name = "${terraform.workspace}_pdm-usage-plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.ndr_doc_store_api_mtls.id
    stage  = aws_api_gateway_stage.ndr_api_mtls.stage_name
  }
}

resource "aws_api_gateway_api_key" "api_key_pdm" {
  name = "${terraform.workspace}_pdm-api-key"
}

resource "aws_api_gateway_usage_plan_key" "api_key_pdm" {
  key_id        = aws_api_gateway_api_key.api_key_pdm.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api_key_pdm.id
}
