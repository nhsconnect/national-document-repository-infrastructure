moved {
  from = module.document_reference_gateway
  to   = module.create_document_reference_gateway
}

#PRME-125
moved {
  from = module.upload_confirm_result_gateway
  to   = module.document-status-check-gateway
}

moved {
  from = module.upload_confirm_result_lambda
  to   = module.document-status-check-lambda
}

moved {
  from = module.upload_confirm_result_alarm
  to   = module.document-status-check-alarm
}

moved {
  from = module.upload_confirm_result_alarm_topic
  to   = module.document-status-check-alarm-topic
}

#NDR-123
moved {
  from = aws_api_gateway_resource.nrl_sandbox
  to   = aws_api_gateway_resource.api_sandbox
}