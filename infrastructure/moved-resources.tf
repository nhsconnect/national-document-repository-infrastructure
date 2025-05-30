# NDR-50

moved {
  from = module.get-doc-nrl-lambda
  to   = module.get-doc-fhir-lambda[0]
}

moved {
  from = aws_iam_role.nrl_get_doc_presign_url_role
  to   = aws_iam_role.get_fhir_doc_presign_url_role[0]
}

moved {
  from = aws_iam_role_policy_attachment.nrl_get_doc_presign_url
  to   = aws_iam_role_policy_attachment.get_doc_presign_url[0]
}

# PRM-28

moved {
  from = module.create-doc-ref-gateway
  to   = module.document_reference_gateway
}