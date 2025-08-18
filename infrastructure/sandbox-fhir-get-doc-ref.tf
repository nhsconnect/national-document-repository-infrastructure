locals {
  mock_200_response = file("${path.module}/fhir_api_mock_responses/get_document_reference/200_response.json")
  mock_401_response = file("${path.module}/fhir_api_mock_responses/get_document_reference/401_response.json")
  mock_403_response = file("${path.module}/fhir_api_mock_responses/get_document_reference/403_response.json")
  mock_404_response = file("${path.module}/fhir_api_mock_responses/get_document_reference/404_response.json")
}

resource "aws_api_gateway_resource" "api_sandbox" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id   = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  path_part   = "sandbox"
}

resource "aws_api_gateway_resource" "sandbox_get_document_reference" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id   = aws_api_gateway_resource.api_sandbox.id
  path_part   = "DocumentReference"
}

resource "aws_api_gateway_resource" "sandbox_get_document_reference_path_parameter" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id   = aws_api_gateway_resource.sandbox_get_document_reference.id
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "sandbox_get_document_reference" {
  rest_api_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id      = aws_api_gateway_resource.sandbox_get_document_reference_path_parameter.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
  request_parameters = {
    "method.request.path.id" = true
  }
}


resource "aws_api_gateway_integration" "get_document_reference_mock" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id = aws_api_gateway_resource.sandbox_get_document_reference_path_parameter.id
  type        = "MOCK"
  http_method = aws_api_gateway_method.sandbox_get_document_reference.http_method
  request_templates = {
    "application/json" = <<EOF
    {
      #if ( $input.params('id') == '16521000000101~f9ed81db-f90a-42d4-b7e4-d554d8f338fd' )
        "statusCode": 200
      #elseif ( $input.params('id') == '401' ) 
        "statusCode": 401 
      #elseif ( $input.params('id') == '403' ) 
        "statusCode": 403
      #else 
        "statusCode": 404    
      #end
    }
    EOF
  }
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id = aws_api_gateway_resource.sandbox_get_document_reference_path_parameter.id
  http_method = aws_api_gateway_method.sandbox_get_document_reference.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "get_document_reference_mock_200_response" {
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = aws_api_gateway_resource.sandbox_get_document_reference_path_parameter.id
  http_method       = aws_api_gateway_method.sandbox_get_document_reference.http_method
  status_code       = aws_api_gateway_method_response.response_200.status_code
  selection_pattern = "200"
  response_templates = {
    "application/json" = local.mock_200_response
  }
}

resource "aws_api_gateway_method_response" "response_401" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id = aws_api_gateway_resource.sandbox_get_document_reference_path_parameter.id
  http_method = aws_api_gateway_method.sandbox_get_document_reference.http_method
  status_code = "401"
}

resource "aws_api_gateway_integration_response" "get_document_reference_mock_401_response" {
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = aws_api_gateway_resource.sandbox_get_document_reference_path_parameter.id
  http_method       = aws_api_gateway_method.sandbox_get_document_reference.http_method
  status_code       = aws_api_gateway_method_response.response_401.status_code
  selection_pattern = "401"
  response_templates = {
    "application/json" = local.mock_401_response
  }
}

resource "aws_api_gateway_method_response" "response_403" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id = aws_api_gateway_resource.sandbox_get_document_reference_path_parameter.id
  http_method = aws_api_gateway_method.sandbox_get_document_reference.http_method
  status_code = "403"
}

resource "aws_api_gateway_integration_response" "get_document_reference_mock_403_response" {
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = aws_api_gateway_resource.sandbox_get_document_reference_path_parameter.id
  http_method       = aws_api_gateway_method.sandbox_get_document_reference.http_method
  status_code       = aws_api_gateway_method_response.response_403.status_code
  selection_pattern = "403"
  response_templates = {
    "application/json" = local.mock_403_response
  }
}

resource "aws_api_gateway_method_response" "response_404" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id = aws_api_gateway_resource.sandbox_get_document_reference_path_parameter.id
  http_method = aws_api_gateway_method.sandbox_get_document_reference.http_method
  status_code = "404"
}

resource "aws_api_gateway_integration_response" "get_document_reference_mock_404_response" {
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = aws_api_gateway_resource.sandbox_get_document_reference_path_parameter.id
  http_method       = aws_api_gateway_method.sandbox_get_document_reference.http_method
  status_code       = aws_api_gateway_method_response.response_404.status_code
  selection_pattern = "404"
  response_templates = {
    "application/json" = local.mock_404_response
  }
}


