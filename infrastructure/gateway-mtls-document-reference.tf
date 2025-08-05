module "fhir_document_reference_gateway_mtls" {
  count               = local.is_production ? 0 : 1
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.mtls_doc_store_api.id
  parent_id           = aws_api_gateway_rest_api.mtls_doc_store_api.root_resource_id
  http_methods        = ["POST", "GET"]
  authorization       = "NONE"
  api_key_required    = true
  gateway_path        = "FhirDocumentReference"
  require_credentials = true
}
