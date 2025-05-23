environment                       = "test"
owner                             = "nhse/ndr-team"
domain                            = "access-request-fulfilment.patient-deductions.nhs.uk"
certificate_domain                = "ndr-test.access-request-fulfilment.patient-deductions.nhs.uk"
certificate_subdomain_name_prefix = "api."

cloudwatch_alarm_evaluation_periods = 5
poll_frequency                      = "10"

standalone_vpc_tag    = "ndr-test"
standalone_vpc_ig_tag = "ndr-test"

apim_environment = "internal-qa."