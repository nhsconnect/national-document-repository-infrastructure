locals {
  search_mock_200_response = file("${path.module}/fhir_api_mock_responses/search_document_reference/200_response.json")
}


resource "aws_api_gateway_method" "sandbox_search_document_reference" {
  rest_api_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id      = aws_api_gateway_resource.sandbox_document_reference.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}


resource "aws_api_gateway_integration" "search_document_reference_mock" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id = aws_api_gateway_resource.sandbox_document_reference.id
  type        = "MOCK"
  http_method = aws_api_gateway_method.sandbox_search_document_reference.http_method
  request_templates = {
    "application/json" = <<EOF
    {
      #if ( $input.params('subject:identifier') == 'https://fhir.nhs.uk/Id/nhs-number%7C900000001' )
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

resource "aws_api_gateway_method_response" "search_document_reference_response_200" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id = aws_api_gateway_resource.sandbox_document_reference.id
  http_method = aws_api_gateway_method.sandbox_search_document_reference.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "search_document_reference_mock_200_response" {
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = aws_api_gateway_resource.sandbox_document_reference.id
  http_method       = aws_api_gateway_method.sandbox_search_document_reference.http_method
  status_code       = aws_api_gateway_method_response.response_200.status_code
  selection_pattern = "200"
  response_templates = {
    "application/json" = local.search_mock_200_response
  }
}

resource "aws_api_gateway_method_response" "search_document_reference_response_401" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id = aws_api_gateway_resource.sandbox_document_reference.id
  http_method = aws_api_gateway_method.sandbox_search_document_reference.http_method
  status_code = "401"
}

resource "aws_api_gateway_integration_response" "search_document_reference_mock_401_response" {
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = aws_api_gateway_resource.sandbox_document_reference.id
  http_method       = aws_api_gateway_method.sandbox_search_document_reference.http_method
  status_code       = aws_api_gateway_method_response.response_401.status_code
  selection_pattern = "401"
  response_templates = {
    "application/json" = local.mock_401_response
  }
}

resource "aws_api_gateway_method_response" "search_document_reference_response_403" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id = aws_api_gateway_resource.sandbox_document_reference.id
  http_method = aws_api_gateway_method.sandbox_search_document_reference.http_method
  status_code = "403"
}

resource "aws_api_gateway_integration_response" "search_document_reference_mock_403_response" {
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = aws_api_gateway_resource.sandbox_document_reference.id
  http_method       = aws_api_gateway_method.sandbox_search_document_reference.http_method
  status_code       = aws_api_gateway_method_response.response_403.status_code
  selection_pattern = "403"
  response_templates = {
    "application/json" = local.mock_403_response
  }
}

resource "aws_api_gateway_method_response" "search_document_reference_response_404" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id = aws_api_gateway_resource.sandbox_document_reference.id
  http_method = aws_api_gateway_method.sandbox_search_document_reference.http_method
  status_code = "404"
}

resource "aws_api_gateway_integration_response" "search_document_reference_mock_404_response" {
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = aws_api_gateway_resource.sandbox_document_reference.id
  http_method       = aws_api_gateway_method.sandbox_search_document_reference.http_method
  status_code       = aws_api_gateway_method_response.response_404.status_code
  selection_pattern = "404"
  response_templates = {
    "application/json" = local.mock_404_response
  }
}


