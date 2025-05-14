environment                       = "dev"
owner                             = "nhse/ndr-team"
domain                            = "access-request-fulfilment.patient-deductions.nhs.uk"
certificate_domain                = "access-request-fulfilment.patient-deductions.nhs.uk"
certificate_subdomain_name_prefix = "api-"

cloudwatch_alarm_evaluation_periods = 5
poll_frequency                      = "3600"

standalone_vpc_tag    = "ndr-dev"
standalone_vpc_ig_tag = "ndr-dev"

cloud_security_email_param_environment = "dev"