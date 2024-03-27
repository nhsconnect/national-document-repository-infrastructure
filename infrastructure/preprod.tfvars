environment                       = "pre-prod"
owner                             = "nhse/ndr-team"
domain                            = "access-request-fulfilment.patient-deductions.nhs.uk"
certificate_domain                = "pre-prod.access-request-fulfilment.patient-deductions.nhs.uk"
certificate_subdomain_name_prefix = "api."

cloudwatch_alarm_evaluation_periods = 30
poll_frequency                      = "60"

mesh_url                        = "https://msg.intspineservices.nhs.uk"
mesh_mailbox_ssm_param_name     = "/repo/pre-prod/user-input/external/mesh-mailbox-id"
mesh_password_ssm_param_name    = "/repo/pre-prod/user-input/external/mesh-mailbox-password"
mesh_shared_key_ssm_param_name  = "/repo/pre-prod/user-input/external/mesh-mailbox-shared-secret"
mesh_client_cert_ssm_param_name = "/repo/pre-prod/user-input/external/mesh-mailbox-client-cert"
mesh_client_key_ssm_param_name  = "/repo/pre-prod/user-input/external/mesh-mailbox-client-key"
mesh_ca_cert_ssm_param_name     = "/repo/pre-prod/user-input/external/mesh-mailbox-ca-cert"

standalone_vpc_tag = "ndr-pre-prod-vpc"