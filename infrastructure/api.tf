# Create Document Store API
resource "aws_api_gateway_rest_api" "ndr_doc_store_api" {
  name        = "${terraform.workspace}-DocStoreAPI"
  description = "Document store API for Repo"

  tags = {
    Name        = "${terraform.workspace}-docstore-api"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

resource "aws_api_gateway_domain_name" "custom_api_domain" {
  domain_name              = local.api_gateway_full_domain_name
  regional_certificate_arn = module.ndr-ecs-fargate.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "api_mapping" {
  api_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  stage_name  = var.environment
  domain_name = local.api_gateway_full_domain_name

  depends_on = [aws_api_gateway_deployment.ndr_api_deploy, aws_api_gateway_rest_api.ndr_doc_store_api]
}

resource "aws_api_gateway_resource" "auth_resource" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id   = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  path_part   = "Auth"
}

# API Config
resource "aws_api_gateway_deployment" "ndr_api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  stage_name  = var.environment

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.ndr_doc_store_api.body,
      module.create-doc-ref-gateway,
      module.create-doc-ref-lambda,
      module.search-patient-details-gateway,
      module.search-patient-details-lambda,
      module.search-document-references-gateway,
      module.search-document-references-lambda,
      module.login_redirect_lambda,
      module.authoriser-lambda,
      module.create-token-lambda,
      module.delete-doc-ref-lambda,
      module.lloyd-george-stitch-lambda,
      module.logout_lambda,
      module.back_channel_logout_lambda
    ]))
  }

  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.create-doc-ref-gateway,
    module.create-doc-ref-lambda,
    module.search-patient-details-gateway,
    module.search-patient-details-lambda,
    module.search-document-references-gateway,
    module.search-document-references-lambda,
    module.login_redirect_lambda,
    module.authoriser-lambda,
    module.create-token-lambda,
    module.delete-doc-ref-lambda,
    module.lloyd-george-stitch-lambda,
    module.logout_lambda,
    module.back_channel_logout_lambda
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_gateway_response" "unauthorised_response" {
  rest_api_id   = aws_api_gateway_rest_api.ndr_doc_store_api.id
  response_type = "DEFAULT_4XX"

  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"      = "'https://${terraform.workspace}.${var.domain}'"
    "gatewayresponse.header.Access-Control-Allow-Methods"     = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Auth,X-Api-Key,X-Amz-Security-Token,X-Auth-Cookie,Accept'"
    "gatewayresponse.header.Access-Control-Allow-Credentials" = "'true'",
  }
}

resource "aws_api_gateway_gateway_response" "bad_gateway_response" {
  rest_api_id   = aws_api_gateway_rest_api.ndr_doc_store_api.id
  response_type = "DEFAULT_5XX"

  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"      = "'https://${terraform.workspace}.${var.domain}'"
    "gatewayresponse.header.Access-Control-Allow-Methods"     = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Auth,X-Api-Key,X-Amz-Security-Token,X-Auth-Cookie,Accept'"
    "gatewayresponse.header.Access-Control-Allow-Credentials" = "'true'",
  }
}

module "api_endpoint_url_ssm_parameter" {
  source              = "./modules/ssm_parameter"
  name                = "api_endpoint"
  description         = "api endpoint url for ${var.environment}"
  resource_depends_on = aws_api_gateway_deployment.ndr_api_deploy
  value               = aws_api_gateway_deployment.ndr_api_deploy.invoke_url
  type                = "SecureString"
  owner               = var.owner
  environment         = var.environment
}

resource "aws_cloudfront_response_headers_policy" "security_headers_policy" {
  name = "${terraform.workspace}-CSP-DocStore"
  security_headers_config {
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "same-origin"
      override        = true
    }
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }
    strict_transport_security {
      access_control_max_age_sec = "63072000"
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
    content_security_policy {
      content_security_policy = "frame-ancestors 'none'; default-src 'none'; img-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'"
      override                = true
    }
  }
}