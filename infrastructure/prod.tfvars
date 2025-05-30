environment                       = "prod"
owner                             = "nhse/ndr-team"
domain                            = "national-document-repository.nhs.uk"
certificate_domain                = "national-document-repository.nhs.uk"
certificate_subdomain_name_prefix = "api."

cloudwatch_alarm_evaluation_periods = 30
poll_frequency                      = "60"

standalone_vpc_tag    = "ndr-prod"
standalone_vpc_ig_tag = "ndr-prod"

apim_environment = ""