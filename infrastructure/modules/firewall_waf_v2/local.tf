locals {

  image_regex = "^\\/images(\\/\\w+)+\\/$"

  waf_rules_raw = [
    {
      name                    = "AWSCoreRuleSet"
      managed_rule_name       = "AWSManagedRulesCommonRuleSet"
      cloudwatch_metrics_name = "AWS-core-ruleset"
      excluded_rules          = []
      bypass                  = ["Yes"]
    },
    {
      name                    = "AWSKnownBadInput"
      managed_rule_name       = "AWSManagedRulesKnownBadInputsRuleSet"
      cloudwatch_metrics_name = "AWS-known-bad-input"
      excluded_rules          = []
      bypass                  = []
    },
    {
      name                    = "AWSSQL"
      managed_rule_name       = "AWSManagedRulesSQLiRuleSet"
      cloudwatch_metrics_name = "AWS-sql-database"
      excluded_rules          = []
      bypass                  = []
    },
    {
      name                    = "AWSIPReputation"
      managed_rule_name       = "AWSManagedRulesAmazonIpReputationList"
      cloudwatch_metrics_name = "AWS-IP-Reputation"
      excluded_rules          = []
      bypass                  = []
    },
    {
      name                    = "AWSLinux"
      managed_rule_name       = "AWSManagedRulesLinuxRuleSet"
      cloudwatch_metrics_name = "AWS-linux-operations"
      excluded_rules          = []
      bypass                  = []
    },
    {
      name                    = "AWSBotControl"
      managed_rule_name       = "AWSManagedRulesBotControlRuleSet"
      cloudwatch_metrics_name = "AWS-Bot-Control"
      excluded_rules          = []
      bypass                  = []
    }
  ]

  # Filter out AWSBotControl if var.api is true
  waf_rules = [
    for rule in local.waf_rules_raw : rule
    if !(var.api && rule.name == "AWSBotControl")
  ]

  waf_rules_map = zipmap(
    range(0, length(local.waf_rules)),
    local.waf_rules
  )
}
