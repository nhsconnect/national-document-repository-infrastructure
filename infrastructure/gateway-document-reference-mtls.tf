module "fhir_document_reference_mtls_gateway" {
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api_mtls.id
  parent_id           = aws_api_gateway_rest_api.ndr_doc_store_api_mtls.root_resource_id
  http_methods        = ["POST", "GET"]
  authorization       = "NONE"
  gateway_path        = "DocumentReference"
  require_credentials = true
}

