environment                       = "pre-prod"
owner                             = "nhse/ndr-team"
domain                            = "national-document-repository.nhs.uk"
certificate_domain                = "pre-prod.national-document-repository.nhs.uk"
certificate_subdomain_name_prefix = "api."

cloudwatch_alarm_evaluation_periods = 30
poll_frequency                      = "60"

standalone_vpc_tag    = "ndr-pre-prod"
standalone_vpc_ig_tag = "ndr-pre-prod"