#!/bin/bash

# source /utils/workspace_utils.sh
#
TERRAFORM_WORKSPACE="$1"

function _list_tagged_resources() {
  local workspace=$1

  if [ -z "$workspace" ]; then
    echo "No workspace provided. Listing all tagged resources..."
    resources=$(aws resourcegroupstaggingapi get-resources --output json)
  else
    echo "Listing resources tagged with Workspace=$workspace"
    resources=$(aws resourcegroupstaggingapi get-resources \
      --tag-filters Key=Workspace,Values="$workspace" \
      --output json)
  fi

  # Extract resource ARNs
  resource_arns=$(echo "$resources" | jq -r '.ResourceTagMappingList[]?.ResourceARN')

  if [ -z "$resource_arns" ]; then
    echo "No tagged resources found."
    return 0
  fi

  # Loop and display
  for arn in $resource_arns; do
    echo "Tagged resource: $arn"
  done
}

function _list_lambdas() {
  local workspace=$1

  if [ -n "$workspace" ]; then
    echo "Filtering by workspace: $workspace"
    FUNCTIONS=$(aws lambda list-functions | jq -r --arg SUBSTRING "$workspace" '.Functions[] | select(.FunctionName | contains($SUBSTRING)) | .FunctionName')
  else
    echo "No workspace specified — listing all Lambda functions"
    FUNCTIONS=$(aws lambda list-functions | jq -r '.Functions[].FunctionName')
  fi

  if [ -z "$FUNCTIONS" ]; then
    echo "No Lambda functions found."
    return 0
  fi

  for FUNCTION_NAME in $FUNCTIONS; do
    echo "Lambda function: $FUNCTION_NAME"
  done
}

function _list_all_kms() {
  local workspace=$1

  if [ -n "$workspace" ]; then
    echo "Filtering KMS aliases by workspace: $workspace"
    ALIASES=$(aws kms list-aliases | jq -r --arg SUBSTRING "$workspace" '.Aliases[] | select(.AliasName | contains($SUBSTRING)) | .AliasName')
  else
    echo "No workspace specified — listing all KMS aliases"
    ALIASES=$(aws kms list-aliases | jq -r '.Aliases[].AliasName')
  fi

  if [ -z "$ALIASES" ]; then
    echo "No KMS aliases found."
    return 0
  fi

  for ALIAS in $ALIASES; do
    # Get the KMS key ID associated with the alias
    KEY_ID=$(aws kms describe-key --key-id "$ALIAS" 2>/dev/null | jq -r '.KeyMetadata.KeyId')

    echo "KMS alias: $ALIAS"
    if [ -n "$KEY_ID" ]; then
      echo "KMS Key ID: $KEY_ID"
    else
      echo "Warning: Could not resolve key ID for alias $ALIAS"
    fi
  done
}

function _list_log_groups() {
  local workspace=$1
  local log_groups

  if [ -n "$workspace" ]; then
    echo "Filtering log groups by workspace: $workspace"
    log_groups=$(aws logs describe-log-groups | jq -r --arg substring "$workspace" '.logGroups[] | select(.logGroupName | contains($substring)) | .logGroupName')
  else
    echo "No workspace specified — listing all log groups"
    log_groups=$(aws logs describe-log-groups | jq -r '.logGroups[].logGroupName')
  fi

  if [ -z "$log_groups" ]; then
    echo "No CloudWatch Logs log groups found."
    return 0
  fi

  for log_group in $log_groups; do
    echo "CloudWatch Logs log group: $log_group"
  done
}

function _delete_log_groups() {
  local workspace=$1
  local log_groups

  # List all log groups and filter those containing the specified substring
  log_groups=$(aws logs describe-log-groups | jq -r --arg substring "$workspace" '.logGroups[] | select(.logGroupName | contains($substring)) | .logGroupName')

  # Check if any log groups were found
  if [ -z "$log_groups" ]; then
    echo "No CloudWatch Logs log groups found containing the substring: $workspace"
    return 0
  fi

  # Loop through each log group and delete it
  for log_group in $log_groups; do
    echo "Deleting CloudWatch Logs log group: $log_group"
    aws logs delete-log-group --log-group-name "$log_group"
  done
}

function _list_dynamo_tables() {
  local workspace=$1
  local tables

  if [ -n "$workspace" ]; then
    echo "Filtering DynamoDB tables by workspace: $workspace"
    tables=$(aws dynamodb list-tables | jq -r --arg substring "$workspace" '.TableNames[] | select(. | contains($substring))')
  else
    echo "No workspace specified — listing all DynamoDB tables"
    tables=$(aws dynamodb list-tables | jq -r '.TableNames[]')
  fi

  if [ -z "$tables" ]; then
    echo "No DynamoDB tables found."
    return 0
  fi

  for table in $tables; do
    echo "DynamoDB table: $table"
  done
}

function _list_s3_buckets() {
  local workspace=$1
  local buckets

  if [ -n "$workspace" ]; then
    echo "Filtering S3 buckets by workspace: $workspace"
    buckets=$(aws s3api list-buckets | jq -r '.Buckets[].Name' | grep -- "$workspace")
  else
    echo "No workspace specified — listing all S3 buckets"
    buckets=$(aws s3api list-buckets | jq -r '.Buckets[].Name')
  fi

  if [ -z "$buckets" ]; then
    echo "No S3 buckets found."
    return 0
  fi

  for bucket in $buckets; do
    echo "S3 bucket: $bucket"
  done
}

function _list_api_gateway() {
  local workspace=$1
  local apis
  local domains

  if [ -n "$workspace" ]; then
    echo "Filtering API Gateway resources by workspace: $workspace"
    apis=$(aws apigateway get-rest-apis --output json | jq -r --arg SUBSTRING "$workspace" '.items[] | select(.name | contains($SUBSTRING)) | .id')
  else
    echo "No workspace specified — listing all API Gateway resources"
    apis=$(aws apigateway get-rest-apis --output json | jq -r '.items[].id')
  fi

  if [ -z "$apis" ]; then
    echo "No API Gateway resources found."
  else
    for api_id in $apis; do
      echo "API Gateway: $api_id"
    done
  fi

  domains=$(aws apigateway get-domain-names --output json | jq -r '.items[].domainName')
  if [ -n "$workspace" ]; then
    for domain in $domains; do
      if [[ $domain == *"$workspace"* ]]; then
        echo "Domain: $domain"
      fi
    done
  else
    for domain in $domains; do
      echo "Domain: $domain"
    done
  fi
}

function _list_ssm_parameters() {
  local workspace=$1
  local params

  if [ -n "$workspace" ]; then
    echo "Filtering SSM Parameters by workspace: $workspace"
    params=$(aws ssm describe-parameters --output json | jq -r --arg SUBSTRING "$workspace" '.Parameters[] | select(.Name | contains($SUBSTRING)) | .Name')
  else
    echo "No workspace specified — listing all SSM Parameters"
    params=$(aws ssm describe-parameters --output json | jq -r '.Parameters[].Name')
  fi

  if [ -z "$params" ]; then
    echo "No SSM Parameters found."
    return 0
  fi

  for param in $params; do
    echo "SSM Parameter: $param"
  done
}

function _list_secrets() {
  local workspace=$1
  local secrets

  if [ -n "$workspace" ]; then
    echo "Filtering Secrets Manager secrets by workspace: $workspace"
    secrets=$(aws secretsmanager list-secrets | jq -r --arg substring "$workspace" '.SecretList[] | select(.Name | contains($substring)) | .ARN')
  else
    echo "No workspace specified — listing all Secrets Manager secrets"
    secrets=$(aws secretsmanager list-secrets | jq -r '.SecretList[].ARN')
  fi

  if [ -z "$secrets" ]; then
    echo "No Secrets Manager secrets found."
    return 0
  fi

  for secret in $secrets; do
    echo "Secrets Manager secret: $secret"
  done
}

function _list_iam() {
  local workspace=$1
  local roles policies

  if [ -n "$workspace" ]; then
    echo "Filtering IAM roles and policies by workspace: $workspace"
    roles=$(aws iam list-roles --output json | jq -r --arg SUBSTRING "$workspace" '.Roles[] | select(.RoleName | contains($SUBSTRING)) | .RoleName')
    policies=$(aws iam list-policies --scope Local --output json | jq -r --arg SUBSTRING "$workspace" '.Policies[] | select(.PolicyName | contains($SUBSTRING)) | .Arn')
  else
    echo "No workspace specified — listing all IAM roles and local policies"
    roles=$(aws iam list-roles --output json | jq -r '.Roles[].RoleName')
    policies=$(aws iam list-policies --scope Local --output json | jq -r '.Policies[].Arn')
  fi

  if [ -z "$roles" ]; then
    echo "No IAM roles found."
  else
    for role in $roles; do
      echo "IAM role: $role"
    done
  fi

  if [ -z "$policies" ]; then
    echo "No IAM policies found."
  else
    for policy_arn in $policies; do
      echo "IAM policy: $policy_arn"
    done
  fi
}

function _list_firehose_delivery_streams() {
  local workspace=$1
  local streams

  if [ -n "$workspace" ]; then
    echo "Filtering Firehose delivery streams by workspace: $workspace"
    streams=$(aws firehose list-delivery-streams --output json | jq -r --arg SUBSTRING "$workspace" '.DeliveryStreamNames[] | select(contains($SUBSTRING))')
  else
    echo "No workspace specified — listing all Firehose delivery streams"
    streams=$(aws firehose list-delivery-streams --output json | jq -r '.DeliveryStreamNames[]')
  fi

  if [ -z "$streams" ]; then
    echo "No Kinesis Data Firehose delivery streams found${workspace:+ containing the substring: $workspace}"
    return 0
  fi

  for stream in $streams; do
    echo "Firehose delivery stream: $stream"
  done
}

function _list_sqs_queues() {
  local workspace=$1
  local queues

  if [ -n "$workspace" ]; then
    echo "Filtering SQS queues by workspace: $workspace"
    queues=$(aws sqs list-queues --output json | jq -r --arg SUBSTRING "$workspace" '.QueueUrls[] | select(contains($SUBSTRING))')
  else
    echo "No workspace specified — listing all SQS queues"
    queues=$(aws sqs list-queues --output json | jq -r '.QueueUrls[]')
  fi

  if [ -z "$queues" ]; then
    echo "No SQS queues found${workspace:+ containing the substring: $workspace}"
    return 0
  fi

  for queue_url in $queues; do
    queue_name=$(basename "$queue_url")
    echo "SQS queue: $queue_name"
  done
}

function _list_step_functions() {
  local workspace=$1
  local state_machines

  if [ -n "$workspace" ]; then
    echo "Filtering Step Functions by workspace: $workspace"
    state_machines=$(aws stepfunctions list-state-machines --output json | jq -r --arg SUBSTRING "$workspace" '.stateMachines[] | select(.name | contains($SUBSTRING)) | .stateMachineArn')
  else
    echo "No workspace specified — listing all Step Functions"
    state_machines=$(aws stepfunctions list-state-machines --output json | jq -r '.stateMachines[].stateMachineArn')
  fi

  if [ -z "$state_machines" ]; then
    echo "No Step Functions found${workspace:+ containing the substring: $workspace}"
    return 0
  fi

  for state_machine_arn in $state_machines; do
    state_machine_name=$(basename "$state_machine_arn")
    echo "Step Function: $state_machine_name"
  done
}

function _list_cloudwatch_events_rules() {
  local workspace=$1
  local rules

  if [ -n "$workspace" ]; then
    echo "Filtering CloudWatch Events rules by workspace: $workspace"
    rules=$(aws events list-rules --output json | jq -r --arg SUBSTRING "$workspace" '.Rules[] | select(.Name | contains($SUBSTRING)) | .Name')
  else
    echo "No workspace specified — listing all CloudWatch Events rules"
    rules=$(aws events list-rules --output json | jq -r '.Rules[].Name')
  fi

  if [ -z "$rules" ]; then
    echo "No CloudWatch Events rules found${workspace:+ containing the substring: $workspace}"
    return 0
  fi

  for rule_name in $rules; do
    echo "CloudWatch Events rule: $rule_name"

    targets=$(aws events list-targets-by-rule --rule "$rule_name" --output json | jq -r '.Targets[].Id')

    if [ -z "$targets" ]; then
      echo "  No targets found for rule: $rule_name"
    else
      for target_id in $targets; do
        echo "  Target $target_id from rule: $rule_name"
      done
    fi
  done
}

function _list_resource_groups() {
  local workspace=$1
  local resource_groups

  if [ -n "$workspace" ]; then
    echo "Filtering Resource Groups by substring: $workspace"
    resource_groups=$(aws resource-groups list-groups --output json | jq -r --arg SUBSTRING "$workspace" '.GroupIdentifiers[] | select(.GroupArn | contains($SUBSTRING)) | .GroupName')
  else
    echo "No workspace specified — listing all Resource Groups"
    resource_groups=$(aws resource-groups list-groups --output json | jq -r '.GroupIdentifiers[].GroupName')
  fi

  if [ -z "$resource_groups" ]; then
    echo "No Resource Groups found${workspace:+ containing the substring: $workspace}"
    return 0
  fi

  for group_name in $resource_groups; do
    echo "Resource Group: $group_name"
  done
}

function _list_backup_vaults() {
  local workspace=$1
  local vaults

  if [ -n "$workspace" ]; then
    echo "Filtering Backup Vaults by substring: $workspace"
    vaults=$(aws backup list-backup-vaults --output json | jq -r --arg SUBSTRING "$workspace" '.BackupVaultList[] | select(.BackupVaultName | contains($SUBSTRING)) | .BackupVaultName')
  else
    echo "No workspace specified — listing all Backup Vaults"
    vaults=$(aws backup list-backup-vaults --output json | jq -r '.BackupVaultList[].BackupVaultName')
  fi

  if [ -z "$vaults" ]; then
    echo "No Backup Vaults found${workspace:+ containing the substring: $workspace}"
    return 0
  fi

  for vault_name in $vaults; do
    echo "Backup Vault: $vault_name"
  done
}

function _list_ecr_repositories() {
  local workspace=$1
  local repos

  if [ -n "$workspace" ]; then
    echo "Filtering ECR repositories by substring: $workspace"
    repos=$(aws ecr describe-repositories --output json | jq -r --arg SUBSTRING "$workspace" '.repositories[] | select(.repositoryName | contains($SUBSTRING)) | .repositoryName')
  else
    echo "No workspace specified — listing all ECR repositories"
    repos=$(aws ecr describe-repositories --output json | jq -r '.repositories[].repositoryName')
  fi

  if [ -z "$repos" ]; then
    echo "No ECR repositories found${workspace:+ containing the substring: $workspace}"
    return 0
  fi

  for repo in $repos; do
    echo "ECR repository: $repo"
  done
}

function _list_ecs_clusters() {
  local workspace=$1
  local clusters

  if [ -n "$workspace" ]; then
    echo "Filtering ECS clusters by substring: $workspace"
    clusters=$(aws ecs list-clusters --output json | jq -r --arg SUBSTRING "$workspace" '.clusterArns[] | select(contains($SUBSTRING))')
  else
    echo "No workspace specified — listing all ECS clusters"
    clusters=$(aws ecs list-clusters --output json | jq -r '.clusterArns[]')
  fi

  if [ -z "$clusters" ]; then
    echo "No ECS clusters found${workspace:+ containing the substring: $workspace}"
    return 0
  fi

  for cluster_arn in $clusters; do
    cluster_name=$(basename "$cluster_arn")
    echo "ECS cluster: $cluster_name"
  done
}

function _list_sns_topics() {
  local workspace=$1
  local topics

  if [ -n "$workspace" ]; then
    echo "Filtering SNS topics by substring: $workspace"
    topics=$(aws sns list-topics --output json | jq -r --arg SUBSTRING "$workspace" '.Topics[] | select(.TopicArn | contains($SUBSTRING)) | .TopicArn')
  else
    echo "No workspace specified — listing all SNS topics"
    topics=$(aws sns list-topics --output json | jq -r '.Topics[].TopicArn')
  fi

  if [ -z "$topics" ]; then
    echo "No SNS topics found${workspace:+ containing the substring: $workspace}"
    return 0
  fi

  for topic_arn in $topics; do
    topic_name=$(basename "$topic_arn")
    echo "SNS topic: $topic_name"
  done
}

function _list_route53_hosted_zones() {
  local workspace=$1
  local zones

  if [ -n "$workspace" ]; then
    echo "Filtering Route 53 hosted zones by substring: $workspace"
    zones=$(aws route53 list-hosted-zones --output json | jq -r --arg SUBSTRING "$workspace" '.HostedZones[] | select(.Name | contains($SUBSTRING)) | .Name')
  else
    echo "No workspace specified — listing all Route 53 hosted zones"
    zones=$(aws route53 list-hosted-zones --output json | jq -r '.HostedZones[].Name')
  fi

  if [ -z "$zones" ]; then
    echo "No Route 53 hosted zones found${workspace:+ containing the substring: $workspace}"
    return 0
  fi

  for zone in $zones; do
    echo "Route 53 hosted zone: $zone"
  done
}

function _list_ses_identities() {
  local workspace=$1
  SUBSTRING="$workspace"

  if [ -z "$SUBSTRING" ]; then
    # No filter - list all identities
    identities=$(aws ses list-identities --output json | jq -r '.Identities[]')
  else
    # Filter by substring
    identities=$(aws ses list-identities --output json | jq -r --arg SUBSTRING "$SUBSTRING" '.Identities[] | select(contains($SUBSTRING))')
  fi

  if [ -z "$identities" ]; then
    echo "No SES identities found${SUBSTRING:+ containing the substring: $SUBSTRING}"
    return 0
  fi

  for identity in $identities; do
    echo "SES identity: $identity"
  done
}

function _list_vpcs() {
  local workspace=$1
  SUBSTRING="$workspace"

  if [ -z "$SUBSTRING" ]; then
    vpcs=$(aws ec2 describe-vpcs --output json | jq -r '.Vpcs[].VpcId')
  else
    vpcs=$(aws ec2 describe-vpcs --output json | jq -r --arg SUBSTRING "$SUBSTRING" '.Vpcs[] | select(.VpcId | contains($SUBSTRING)) | .VpcId')
  fi

  if [ -z "$vpcs" ]; then
    echo "No VPCs found${SUBSTRING:+ containing the substring: $SUBSTRING}"
    return 0
  fi

  for vpc in $vpcs; do
    echo "VPC: $vpc"
  done
}

function _list_subnets() {
  local workspace=$1
  SUBSTRING="$workspace"

  if [ -z "$SUBSTRING" ]; then
    subnets=$(aws ec2 describe-subnets --output json | jq -r '.Subnets[].SubnetId')
  else
    subnets=$(aws ec2 describe-subnets --output json | jq -r --arg SUBSTRING "$SUBSTRING" '.Subnets[] | select(.SubnetId | contains($SUBSTRING)) | .SubnetId')
  fi

  if [ -z "$subnets" ]; then
    echo "No subnets found${SUBSTRING:+ containing the substring: $SUBSTRING}"
    return 0
  fi

  for subnet in $subnets; do
    echo "Subnet: $subnet"
  done
}

function _list_wafv2_web_acls() {
  local workspace=$1
  local filter="."

  if [ -n "$workspace" ]; then
    filter="select(.Name | contains(\"$workspace\"))"
  fi

  echo "WAFv2 Web ACLs (Scope: REGIONAL)"
  regional_acls=$(aws wafv2 list-web-acls --scope REGIONAL --output json | jq -r ".WebACLs[] | $filter | .Name")

  if [ -z "$regional_acls" ]; then
    echo "  No REGIONAL Web ACLs found${workspace:+ matching \"$workspace\"}"
  else
    for acl in $regional_acls; do
      echo "  REGIONAL Web ACL: $acl"
    done
  fi

  echo "WAFv2 Web ACLs (Scope: CLOUDFRONT)"
  cloudfront_acls=$(aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1 --output json | jq -r ".WebACLs[] | $filter | .Name")

  if [ -z "$cloudfront_acls" ]; then
    echo "  No CLOUDFRONT Web ACLs found${workspace:+ matching \"$workspace\"}"
  else
    for acl in $cloudfront_acls; do
      echo "  CLOUDFRONT Web ACL: $acl"
    done
  fi
}

function _list_cloudfront_distributions() {
  local workspace=$1
  SUBSTRING="$workspace"

  if [ -z "$SUBSTRING" ]; then
    dists=$(aws cloudfront list-distributions --output json | jq -r '.DistributionList.Items[].Id')
  else
    dists=$(aws cloudfront list-distributions --output json | jq -r --arg SUBSTRING "$SUBSTRING" '.DistributionList.Items[] | select(.Id | contains($SUBSTRING)) | .Id')
  fi

  if [ -z "$dists" ]; then
    echo "No CloudFront distributions found${SUBSTRING:+ containing the substring: $SUBSTRING}"
    return 0
  fi

  for dist in $dists; do
    echo "CloudFront distribution: $dist"
  done
}

function _list_cloudwatch_metrics() {
  local workspace=$1
  SUBSTRING="$workspace"

  if [ -z "$SUBSTRING" ]; then
    metrics=$(aws cloudwatch list-metrics --output json | jq -r '.Metrics[].MetricName' | sort -u)
  else
    metrics=$(aws cloudwatch list-metrics --output json | jq -r --arg SUBSTRING "$SUBSTRING" '.Metrics[] | select(.MetricName | contains($SUBSTRING)) | .MetricName' | sort -u)
  fi

  if [ -z "$metrics" ]; then
    echo "No CloudWatch metrics found${SUBSTRING:+ containing the substring: $SUBSTRING}"
    return 0
  fi

  for metric in $metrics; do
    echo "CloudWatch metric: $metric"
  done
}

function _list_cloudwatch_alarms() {
  local workspace=$1
  SUBSTRING="$workspace"

  if [ -z "$SUBSTRING" ]; then
    alarms=$(aws cloudwatch describe-alarms --output json | jq -r '.MetricAlarms[].AlarmName')
  else
    alarms=$(aws cloudwatch describe-alarms --output json | jq -r --arg SUBSTRING "$SUBSTRING" '.MetricAlarms[] | select(.AlarmName | contains($SUBSTRING)) | .AlarmName')
  fi

  if [ -z "$alarms" ]; then
    echo "No CloudWatch alarms found${SUBSTRING:+ containing the substring: $SUBSTRING}"
    return 0
  fi

  for alarm in $alarms; do
    echo "CloudWatch alarm: $alarm"
  done
}

function _delete_cloudwatch_alarms() {
  local workspace=$1

  alarms=$(aws cloudwatch describe-alarms --output json | jq -r --arg SUBSTRING "$workspace" '.MetricAlarms[] | select(.AlarmName | contains($SUBSTRING)) | .AlarmName')

  if [ -z "$alarms" ]; then
    echo "No CloudWatch alarms containing the substring: $workspace"
    return 0
  fi

  echo "Deleting the following CloudWatch alarms:"
  for alarm in $alarms; do
    echo "$alarm"
  done
  aws cloudwatch delete-alarms --alarm-names $alarms
}

function _list_appconfig() {
  local workspace=$1
  SUBSTRING="$workspace"

  if [ -z "$SUBSTRING" ]; then
    apps=$(aws appconfig list-applications --output json | jq -r '.Items[].Name')
  else
    apps=$(aws appconfig list-applications --output json | jq -r --arg SUBSTRING "$SUBSTRING" '.Items[] | select(.Name | contains($SUBSTRING)) | .Name')
  fi

  if [ -z "$apps" ]; then
    echo "No AppConfig applications found${SUBSTRING:+ containing the substring: $SUBSTRING}"
    return 0
  fi

  for app in $apps; do
    echo "AppConfig application: $app"
  done
}

function _list_lambda_layers() {
  local workspace=$1
  local layers=$(aws lambda list-layers --output json)

  if [ -n "$workspace" ]; then
    echo "Listing Lambda Layers containing: $workspace"
    layers=$(echo "$layers" | jq -r --arg SUBSTRING "$workspace" '.Layers[] | select(.LayerName | contains($SUBSTRING)) | .LayerName')
  else
    echo "Listing all Lambda Layers"
    layers=$(echo "$layers" | jq -r '.Layers[] | .LayerName')
  fi

  [ -z "$layers" ] && echo "No Lambda Layers found." && return 0

  for layer in $layers; do
    echo "Lambda Layer: $layer"
  done
}

function _delete_lambda_layers() {
  local workspace=$1
  local layers=$(aws lambda list-layers --output json)

  if [ -n "$workspace" ]; then
    layers=$(echo "$layers" | jq -r --arg SUBSTRING "$workspace" '.Layers[] | select(.LayerName | contains($SUBSTRING)) | .LayerName')
  fi

  [ -z "$layers" ] && echo "No Lambda Layers found containing substring: $workspace" && return 0

  for layer in $layers; do
    echo "Deleting versions for Lambda Layer: $layer"
    versions=$(aws lambda list-layer-versions --layer-name "$layer" --output json | jq -r '.LayerVersions[].Version')
    for v in $versions; do
      echo "  - Deleting $layer version $v"
      aws lambda delete-layer-version --layer-name "$layer" --version-number "$v"
    done
  done

}

function _list_cloudwatch_dashboards() {
  local workspace=$1
  local dashboards=$(aws cloudwatch list-dashboards --output json)

  if [ -n "$workspace" ]; then
    echo "Listing CloudWatch Dashboards containing: $workspace"
    dashboards=$(echo "$dashboards" | jq -r --arg SUBSTRING "$workspace" '.DashboardEntries[] | select(.DashboardName | contains($SUBSTRING)) | .DashboardName')
  else
    echo "Listing all CloudWatch Dashboards"
    dashboards=$(echo "$dashboards" | jq -r '.DashboardEntries[] | .DashboardName')
  fi

  [ -z "$dashboards" ] && echo "No CloudWatch Dashboards found." && return 0

  for dashboard in $dashboards; do
    echo "CloudWatch Dashboard: $dashboard"
  done
}

function _list_iam_instance_profiles() {
  local workspace=$1
  local profiles=$(aws iam list-instance-profiles --output json)

  if [ -n "$workspace" ]; then
    echo "Listing IAM Instance Profiles containing: $workspace"
    profiles=$(echo "$profiles" | jq -r --arg SUBSTRING "$workspace" '.InstanceProfiles[] | select(.InstanceProfileName | contains($SUBSTRING)) | .InstanceProfileName')
  else
    echo "Listing all IAM Instance Profiles"
    profiles=$(echo "$profiles" | jq -r '.InstanceProfiles[] | .InstanceProfileName')
  fi

  [ -z "$profiles" ] && echo "No IAM Instance Profiles found." && return 0

  for profile in $profiles; do
    echo "IAM Instance Profile: $profile"
  done
}

function _list_vpc_endpoints() {
  local workspace=$1
  local endpoints=$(aws ec2 describe-vpc-endpoints --output json)

  if [ -n "$workspace" ]; then
    echo "Listing VPC Endpoints containing: $workspace"
    endpoints=$(echo "$endpoints" | jq -r --arg SUBSTRING "$workspace" '.VpcEndpoints[] | select(.VpcEndpointId | contains($SUBSTRING) or .ServiceName | contains($SUBSTRING) or .Tags[]?.Value | contains($SUBSTRING)) | .VpcEndpointId')
  else
    echo "Listing all VPC Endpoints"
    endpoints=$(echo "$endpoints" | jq -r '.VpcEndpoints[] | .VpcEndpointId')
  fi

  [ -z "$endpoints" ] && echo "No VPC Endpoints found." && return 0

  for endpoint in $endpoints; do
    echo "VPC Endpoint: $endpoint"
  done
}

function _list_efs_file_systems() {
  local workspace=$1
  local filesystems=$(aws efs describe-file-systems --output json)

  if [ -n "$workspace" ]; then
    echo "Listing EFS File Systems containing: $workspace"
    filesystems=$(echo "$filesystems" | jq -r --arg SUBSTRING "$workspace" '.FileSystems[] | select(.Name | contains($SUBSTRING) or .FileSystemId | contains($SUBSTRING)) | .FileSystemId')
  else
    echo "Listing all EFS File Systems"
    filesystems=$(echo "$filesystems" | jq -r '.FileSystems[] | .FileSystemId')
  fi

  [ -z "$filesystems" ] && echo "No EFS File Systems found." && return 0

  for fs in $filesystems; do
    echo "EFS File System: $fs"
  done
}

function _list_elbs() {
  local workspace=$1
  local elbs=$(aws elbv2 describe-load-balancers --output json)

  if [ -n "$workspace" ]; then
    echo "Listing ELBs containing: $workspace"
    elbs=$(echo "$elbs" | jq -r --arg SUBSTRING "$workspace" '.LoadBalancers[] | select(.LoadBalancerName | contains($SUBSTRING)) | .LoadBalancerName')
  else
    echo "Listing all ELBs"
    elbs=$(echo "$elbs" | jq -r '.LoadBalancers[] | .LoadBalancerName')
  fi

  [ -z "$elbs" ] && echo "No Elastic Load Balancers found." && return 0

  for elb in $elbs; do
    echo "Elastic Load Balancer: $elb"
  done
}

function _list_target_groups() {
  local workspace=$1
  local tgs=$(aws elbv2 describe-target-groups --output json)

  if [ -n "$workspace" ]; then
    echo "Listing Target Groups containing: $workspace"
    tgs=$(echo "$tgs" | jq -r --arg SUBSTRING "$workspace" '.TargetGroups[] | select(.TargetGroupName | contains($SUBSTRING)) | .TargetGroupName')
  else
    echo "Listing all Target Groups"
    tgs=$(echo "$tgs" | jq -r '.TargetGroups[] | .TargetGroupName')
  fi

  [ -z "$tgs" ] && echo "No Target Groups found." && return 0

  for tg in $tgs; do
    echo "Target Group: $tg"
  done
}

function _list_cognito_pools() {
  local workspace=$1

  echo "⚠️ Note: Cognito APIs are regional — you may need to loop over regions."

  user_pools=$(aws cognito-idp list-user-pools --max-results 60 --output json)

  if [ -n "$workspace" ]; then
    echo "Listing Cognito User Pools containing: $workspace"
    user_pools=$(echo "$user_pools" | jq -r --arg SUBSTRING "$workspace" '.UserPools[] | select(.Name | contains($SUBSTRING)) | .Name')
  else
    echo "Listing all Cognito User Pools"
    user_pools=$(echo "$user_pools" | jq -r '.UserPools[] | .Name')
  fi

  [ -z "$user_pools" ] && echo "No Cognito User Pools found." || for up in $user_pools; do
    echo "Cognito User Pool: $up"
  done

  identity_pools=$(aws cognito-identity list-identity-pools --max-results 60 --output json)

  if [ -n "$workspace" ]; then
    identity_pools=$(echo "$identity_pools" | jq -r --arg SUBSTRING "$workspace" '.IdentityPools[] | select(.IdentityPoolName | contains($SUBSTRING)) | .IdentityPoolName')
  else
    identity_pools=$(echo "$identity_pools" | jq -r '.IdentityPools[] | .IdentityPoolName')
  fi

  [ -z "$identity_pools" ] && echo "No Cognito Identity Pools found." || for ip in $identity_pools; do
    echo "Cognito Identity Pool: $ip"
  done
}

function _list_eventbridge_buses() {
  local workspace=$1
  local buses=$(aws events list-event-buses --output json)

  if [ -n "$workspace" ]; then
    buses=$(echo "$buses" | jq -r --arg SUBSTRING "$workspace" '.EventBuses[] | select(.Name | contains($SUBSTRING)) | .Name')
  else
    buses=$(echo "$buses" | jq -r '.EventBuses[] | .Name')
  fi

  [ -z "$buses" ] && echo "No EventBridge Buses found." && return 0

  for bus in $buses; do
    echo "EventBridge Bus: $bus"
  done
}

function _list_sns_subscriptions() {
  local workspace=$1
  local subs=$(aws sns list-subscriptions --output json)

  if [ -n "$workspace" ]; then
    subs=$(echo "$subs" | jq -r --arg SUBSTRING "$workspace-sns" ' .Subscriptions[] | select((.SubscriptionArn | contains($SUBSTRING)) or (.TopicArn | contains($SUBSTRING))) | .SubscriptionArn')
  else
    subs=$(echo "$subs" | jq -r '.Subscriptions[] | .SubscriptionArn')
  fi

  [ -z "$subs" ] && echo "No SNS Subscriptions found." && return 0

  for sub in $subs; do
    echo "SNS Subscription: $sub"
  done
}

function _delete_sns_subscriptions() {
  local workspace=$1
  local subs=$(aws sns list-subscriptions --output json)
  subs=$(echo "$subs" | jq -r --arg SUBSTRING "$workspace-sns" ' .Subscriptions[] | select((.SubscriptionArn | contains($SUBSTRING)) or (.TopicArn | contains($SUBSTRING))) | .SubscriptionArn')
  [ -z "$subs" ] && echo "No SNS Subscriptions found for $workspace" && return 0

  for sub in $subs; do
    echo "SNS Subscription: $sub"
  done
}

function _list_lambda_event_source_mappings() {
  local workspace=$1
  local mappings=$(aws lambda list-event-source-mappings --output json)

  if [ -n "$workspace" ]; then
    mappings=$(echo "$mappings" | jq -r --arg SUBSTRING "$workspace" '.EventSourceMappings[] | select(.FunctionArn | contains($SUBSTRING)) | .UUID')
  else
    mappings=$(echo "$mappings" | jq -r '.EventSourceMappings[] | .UUID')
  fi

  [ -z "$mappings" ] && echo "No Lambda Event Source Mappings found." && return 0

  for mapping in $mappings; do
    echo "Lambda Event Source Mapping UUID: $mapping"
  done
}

function _list_workspace_resources() {
  _list_tagged_resources "$TERRAFORM_WORKSPACE"
  _list_lambdas "$TERRAFORM_WORKSPACE"
  _list_all_kms "$TERRAFORM_WORKSPACE"
  _list_log_groups "$TERRAFORM_WORKSPACE"
  _list_secrets "$TERRAFORM_WORKSPACE"
  _list_s3_buckets "$TERRAFORM_WORKSPACE"
  _list_dynamo_tables "$TERRAFORM_WORKSPACE"
  _list_api_gateway "$TERRAFORM_WORKSPACE"
  _list_ssm_parameters "$TERRAFORM_WORKSPACE"
  _list_firehose_delivery_streams "$TERRAFORM_WORKSPACE"
  _list_sqs_queues "$TERRAFORM_WORKSPACE"
  _list_step_functions "$TERRAFORM_WORKSPACE"
  _list_cloudwatch_events_rules "$TERRAFORM_WORKSPACE"
  # # _list_acm_certificates "$workspace"
  _list_iam "$TERRAFORM_WORKSPACE"
  _list_resource_groups "$TERRAFORM_WORKSPACE"
  _list_backup_vaults "$TERRAFORM_WORKSPACE"
  _list_ecs_clusters "$TERRAFORM_WORKSPACE"
  _list_ecr_repositories "$TERRAFORM_WORKSPACE"
  _list_sns_topics "$TERRAFORM_WORKSPACE"
  _list_route53_hosted_zones "$TERRAFORM_WORKSPACE"
  _list_ses_identities "$TERRAFORM_WORKSPACE"
  _list_vpcs "$TERRAFORM_WORKSPACE"
  _list_subnets "$TERRAFORM_WORKSPACE"
  _list_wafv2_web_acls "$TERRAFORM_WORKSPACE"
  _list_cloudfront_distributions "$TERRAFORM_WORKSPACE"
  _list_cloudwatch_metrics "$TERRAFORM_WORKSPACE"
  _list_cloudwatch_alarms "$TERRAFORM_WORKSPACE"
  _list_appconfig "$TERRAFORM_WORKSPACE"
  _list_lambda_layers "$TERRAFORM_WORKSPACE"
  _list_iam_instance_profiles "$TERRAFORM_WORKSPACE"
  _list_cloudwatch_dashboards "$TERRAFORM_WORKSPACE"
  _list_vpc_endpoints "$TERRAFORM_WORKSPACE"
  _list_efs_file_systems "$TERRAFORM_WORKSPACE"
  _list_elbs "$TERRAFORM_WORKSPACE"
  _list_target_groups "$TERRAFORM_WORKSPACE"
  _list_cognito_pools "$TERRAFORM_WORKSPACE"
  _list_eventbridge_buses "$TERRAFORM_WORKSPACE"
  _list_sns_subscriptions "$TERRAFORM_WORKSPACE"
  _list_lambda_event_source_mappings "$TERRAFORM_WORKSPACE"
}

function _delete_workspace_resources() {
  _delete_log_groups "$TERRAFORM_WORKSPACE"
  _delete_lambda_layers "$TERRAFORM_WORKSPACE"
  _delete_cloudwatch_alarms "$TERRAFORM_WORKSPACE"
  _delete_sns_subscriptions "$TERRAFORM_WORKSPACE"
}

_list_workspace_resources
# _delete_workspace_resources

# CloudWatch Logs log group: /aws/ecs/containerinsights/mockcis2-app-cluster/performance
# CloudWatch Logs log group: /aws/ecs/containerinsights/ndrv-app-cluster/performance
# CloudWatch Logs log group: /aws/ecs/containerinsights/prmt371-app-cluster/performance
# CloudWatch Logs log group: /aws/ecs/containerinsights/test439-app-cluster/performance
#
# CloudWatch Logs log group: /aws/lambda/AuthoriserHandler
# CloudWatch Logs log group: /aws/lambda/BackChannelLogoutHandler
# CloudWatch Logs log group: /aws/lambda/CreateDocumentManifestByNhsNumber
# CloudWatch Logs log group: /aws/lambda/CreateDocumentManifestByNhsNumberHandler
# CloudWatch Logs log group: /aws/lambda/CreateDocumentReferenceHandler
# CloudWatch Logs log group: /aws/lambda/DeleteDocumentReferenceHandler
# CloudWatch Logs log group: /aws/lambda/DocumentReferenceSearch
# CloudWatch Logs log group: /aws/lambda/DocumentReferenceSearchHandler
# CloudWatch Logs log group: /aws/lambda/DocumentUploadedEventHandler
# CloudWatch Logs log group: /aws/lambda/FakeVirusScannedEvent
# CloudWatch Logs log group: /aws/lambda/FakeVirusScannedEventHandler
# CloudWatch Logs log group: /aws/lambda/LoginRedirectHandler
# CloudWatch Logs log group: /aws/lambda/LogoutHandler
# CloudWatch Logs log group: /aws/lambda/NetworkToolSSMRunbookExecution26ae07613162
# CloudWatch Logs log group: /aws/lambda/NetworkToolSSMRunbookExecutione93d9e58d02d
# CloudWatch Logs log group: /aws/lambda/PRMT371_NhsOauthTokenGeneratorLambda
# CloudWatch Logs log group: /aws/lambda/ReRegistrationEventHandler
# CloudWatch Logs log group: /aws/lambda/RetrieveDocumentReferenceHandler
# CloudWatch Logs log group: /aws/lambda/RetrievePatientDetailsHandler
# CloudWatch Logs log group: /aws/lambda/SearchPatientDetailsHandler
# CloudWatch Logs log group: /aws/lambda/TestLambda
# CloudWatch Logs log group: /aws/lambda/TokenRequestHandler
# CloudWatch Logs log group: /aws/lambda/VirusScannedEvent
# CloudWatch Logs log group: /aws/lambda/VirusScannedEventHandler
# CloudWatch Logs log group: /aws/lambda/default_BulkUploadMetadataLambda
# CloudWatch Logs log group: /aws/lambda/default_BulkUploadReportLambda
# CloudWatch Logs log group: /aws/lambda/delete1_BulkUploadMetadataLambda
# CloudWatch Logs log group: /aws/lambda/delete1_BulkUploadReportLambda
# CloudWatch Logs log group: /aws/lambda/delete1_NhsOauthTokenGeneratorLambda
# CloudWatch Logs log group: /aws/lambda/delete2_NhsOauthTokenGeneratorLambda
# CloudWatch Logs log group: /aws/lambda/delete3_NhsOauthTokenGeneratorLambda
# CloudWatch Logs log group: /aws/lambda/delete_NhsOauthTokenGeneratorLambda
# CloudWatch Logs log group: /aws/lambda/dev_AuthoriserHandler
# CloudWatch Logs log group: /aws/lambda/dev_BackChannelLogoutHandler
# CloudWatch Logs log group: /aws/lambda/dev_CreateDocumentManifestByNhsNumberHandler
# CloudWatch Logs log group: /aws/lambda/dev_CreateDocumentReferenceHandler
# CloudWatch Logs log group: /aws/lambda/dev_DeleteDocumentReferenceHandler
# CloudWatch Logs log group: /aws/lambda/dev_DocumentReferenceSearchHandler
# CloudWatch Logs log group: /aws/lambda/dev_FakeVirusScannedEventHandler
# CloudWatch Logs log group: /aws/lambda/dev_LoginRedirectHandler
# CloudWatch Logs log group: /aws/lambda/dev_LogoutHandler
# CloudWatch Logs log group: /aws/lambda/dev_ReRegistrationEventHandler
# CloudWatch Logs log group: /aws/lambda/dev_SearchPatientDetailsHandler
# CloudWatch Logs log group: /aws/lambda/dev_TokenRequestHandler
# CloudWatch Logs log group: /aws/lambda/dev_VerifyOrganisationHandler
# CloudWatch Logs log group: /aws/lambda/dev_VirusScannedEventHandler
# CloudWatch Logs log group: /aws/lambda/java-basic-function-c2sr4GMnwLbc
# CloudWatch Logs log group: /aws/lambda/mockcis2_AuthoriserLambda
# CloudWatch Logs log group: /aws/lambda/mockcis2_BulkUploadLambda
# CloudWatch Logs log group: /aws/lambda/mockcis2_BulkUploadMetadataLambda
# CloudWatch Logs log group: /aws/lambda/mockcis2_BulkUploadReportLambda
# CloudWatch Logs log group: /aws/lambda/mockcis2_CreateDocRefLambda
# CloudWatch Logs log group: /aws/lambda/mockcis2_DataCollectionLambda
# CloudWatch Logs log group: /aws/lambda/mockcis2_DeleteDocumentObjectS3
# CloudWatch Logs log group: /aws/lambda/mockcis2_DocumentManifestJobLambda
# CloudWatch Logs log group: /aws/lambda/mockcis2_FeatureFlagsLambda
# CloudWatch Logs log group: /aws/lambda/mockcis2_GenerateDocumentManifest
# CloudWatch Logs log group: /aws/lambda/mockcis2_GenerateLloydGeorgeStitch
# CloudWatch Logs log group: /aws/lambda/mockcis2_GetReportByODS
# CloudWatch Logs log group: /aws/lambda/mockcis2_LloydGeorgeStitchLambda
# CloudWatch Logs log group: /aws/lambda/mockcis2_LoginRedirectHandler
# CloudWatch Logs log group: /aws/lambda/mockcis2_LogoutHandler
# CloudWatch Logs log group: /aws/lambda/mockcis2_NhsOauthTokenGeneratorLambda
# CloudWatch Logs log group: /aws/lambda/mockcis2_PdfStitchingLambda
# CloudWatch Logs log group: /aws/lambda/mockcis2_SearchDocumentReferencesLambda
# CloudWatch Logs log group: /aws/lambda/mockcis2_SearchPatientDetailsLambda
# CloudWatch Logs log group: /aws/lambda/mockcis2_StatisticalReportLambda
# CloudWatch Logs log group: /aws/lambda/mockcis2_TokenRequestHandler
# CloudWatch Logs log group: /aws/lambda/mockcis2_VirusScanResult
# CloudWatch Logs log group: /aws/lambda/ndr-101_DocumentReferenceVirusScanCheck
# CloudWatch Logs log group: /aws/lambda/ndr-101_NhsOauthTokenGeneratorLambda
# CloudWatch Logs log group: /aws/lambda/ndr-b_BulkUploadMetadataLambda
# CloudWatch Logs log group: /aws/lambda/ndr-b_BulkUploadReportLambda
# CloudWatch Logs log group: /aws/lambda/ndr-demo_BulkUploadMetadataLambda
# CloudWatch Logs log group: /aws/lambda/ndr-demo_BulkUploadReportLambda
# CloudWatch Logs log group: /aws/lambda/ndr-demo_LoginRedirectHandler
# CloudWatch Logs log group: /aws/lambda/ndr-test_AuthoriserLambda
# CloudWatch Logs log group: /aws/lambda/ndr-test_BackChannelLogoutHandler
# CloudWatch Logs log group: /aws/lambda/ndr-test_BulkUploadLambda
# CloudWatch Logs log group: /aws/lambda/ndr-test_BulkUploadMetadataLambda
# CloudWatch Logs log group: /aws/lambda/ndr-test_BulkUploadReportLambda
# CloudWatch Logs log group: /aws/lambda/ndr-test_CreateDocRefLambda
# CloudWatch Logs log group: /aws/lambda/ndr-test_DeleteDocRefLambda
# CloudWatch Logs log group: /aws/lambda/ndr-test_DocumentManifestByNHSNumberLambda
# CloudWatch Logs log group: /aws/lambda/ndr-test_FeatureFlagsLambda
# CloudWatch Logs log group: /aws/lambda/ndr-test_LloydGeorgeStitchLambda
# CloudWatch Logs log group: /aws/lambda/ndr-test_LoginRedirectHandler
# CloudWatch Logs log group: /aws/lambda/ndr-test_LogoutHandler
# CloudWatch Logs log group: /aws/lambda/ndr-test_SearchDocumentReferencesLambda
# CloudWatch Logs log group: /aws/lambda/ndr-test_SearchPatientDetailsLambda
# CloudWatch Logs log group: /aws/lambda/ndr-test_SendFeedbackLambda
# CloudWatch Logs log group: /aws/lambda/ndr-test_TokenRequestHandler
# CloudWatch Logs log group: /aws/lambda/ndr-test_UploadConfirmResultLambda
# CloudWatch Logs log group: /aws/lambda/ndr-test_VirusScanResult
# CloudWatch Logs log group: /aws/lambda/ndr194_NhsOauthTokenGeneratorLambda
# CloudWatch Logs log group: /aws/lambda/ndr_dev_CreateDocRefLAmbda
# CloudWatch Logs log group: /aws/lambda/ndr_dev_CreateDocRefLambda
# CloudWatch Logs log group: /aws/lambda/ndr_pdf_stitching
# CloudWatch Logs log group: /aws/lambda/prme16_NhsOauthTokenGeneratorLambda
# CloudWatch Logs log group: /aws/lambda/prmt-3343_LoginRedirectHandler
# CloudWatch Logs log group: /aws/lambda/prmt-3343_ReRegistrationEventHandler
# CloudWatch Logs log group: /aws/lambda/prmt-3343_VirusScannedEventHandler
# CloudWatch Logs log group: /aws/lambda/prmt371_AuthoriserLambda
# CloudWatch Logs log group: /aws/lambda/prmt371_BulkUploadLambda
# CloudWatch Logs log group: /aws/lambda/prmt371_BulkUploadMetadataLambda
# CloudWatch Logs log group: /aws/lambda/prmt371_BulkUploadReportLambda
# CloudWatch Logs log group: /aws/lambda/prmt371_DataCollectionLambda
# CloudWatch Logs log group: /aws/lambda/prmt371_DeleteDocRefLambda
# CloudWatch Logs log group: /aws/lambda/prmt371_DocumentManifestJobLambda
# CloudWatch Logs log group: /aws/lambda/prmt371_FeatureFlagsLambda
# CloudWatch Logs log group: /aws/lambda/prmt371_GenerateDocumentManifest
# CloudWatch Logs log group: /aws/lambda/prmt371_GenerateLloydGeorgeStitch
# CloudWatch Logs log group: /aws/lambda/prmt371_GetReportByODS
# CloudWatch Logs log group: /aws/lambda/prmt371_LloydGeorgeStitchLambda
# CloudWatch Logs log group: /aws/lambda/prmt371_LoginRedirectHandler
# CloudWatch Logs log group: /aws/lambda/prmt371_LogoutHandler
# CloudWatch Logs log group: /aws/lambda/prmt371_NhsOauthTokenGeneratorLambda
# CloudWatch Logs log group: /aws/lambda/prmt371_PdfStitchingLambda
# CloudWatch Logs log group: /aws/lambda/prmt371_SearchDocumentReferencesLambda
# CloudWatch Logs log group: /aws/lambda/prmt371_SearchPatientDetailsLambda
# CloudWatch Logs log group: /aws/lambda/prmt371_StatisticalReportLambda
# CloudWatch Logs log group: /aws/lambda/prmt371_TokenRequestHandler
# CloudWatch Logs log group: /aws/lambda/rich-test_VirusScannedEventHandler
# CloudWatch Logs log group: /aws/lambda/sanda_AuthoriserHandler
# CloudWatch Logs log group: /aws/lambda/sanda_CreateDocumentManifestByNhsNumberHandler
# CloudWatch Logs log group: /aws/lambda/sanda_CreateDocumentReferenceHandler
# CloudWatch Logs log group: /aws/lambda/sanda_DeleteDocumentReferenceHandler
# CloudWatch Logs log group: /aws/lambda/sanda_DocumentReferenceSearchHandler
# CloudWatch Logs log group: /aws/lambda/sanda_FakeVirusScannedEventHandler
# CloudWatch Logs log group: /aws/lambda/sanda_LoginRedirectHandler
# CloudWatch Logs log group: /aws/lambda/sanda_LogoutHandler
# CloudWatch Logs log group: /aws/lambda/sanda_ReRegistrationEventHandler
# CloudWatch Logs log group: /aws/lambda/sanda_SearchPatientDetailsHandler
# CloudWatch Logs log group: /aws/lambda/sanda_TokenRequestHandler
# CloudWatch Logs log group: /aws/lambda/sanda_VerifyOrganisationHandler
# CloudWatch Logs log group: /aws/lambda/sanda_VirusScannedEventHandler
# CloudWatch Logs log group: /aws/lambda/sandb_AuthoriserHandler
# CloudWatch Logs log group: /aws/lambda/sandb_CreateDocumentManifestByNhsNumberHandler
# CloudWatch Logs log group: /aws/lambda/sandb_CreateDocumentReferenceHandler
# CloudWatch Logs log group: /aws/lambda/sandb_DeleteDocumentReferenceHandler
# CloudWatch Logs log group: /aws/lambda/sandb_DocumentReferenceSearchHandler
# CloudWatch Logs log group: /aws/lambda/sandb_FakeVirusScannedEventHandler
# CloudWatch Logs log group: /aws/lambda/sandb_LoginRedirectHandler
# CloudWatch Logs log group: /aws/lambda/sandb_LogoutHandler
# CloudWatch Logs log group: /aws/lambda/sandb_ReRegistrationEventHandler
# CloudWatch Logs log group: /aws/lambda/sandb_SearchPatientDetailsHandler
# CloudWatch Logs log group: /aws/lambda/sandb_TokenRequestHandler
# CloudWatch Logs log group: /aws/lambda/sandb_VerifyOrganisationHandler
# CloudWatch Logs log group: /aws/lambda/sandb_VirusScannedEventHandler
# CloudWatch Logs log group: /aws/lambda/serverlessrepo-lambda-janitor-Clean-UvqCAGGNm2ps
# CloudWatch Logs log group: /aws/lambda/spike914
# CloudWatch Logs log group: /aws/lambda/spike_prmdr_855_reporting_data
# CloudWatch Logs log group: /aws/lambda/teams_alert
# CloudWatch Logs log group: /aws/lambda/test
# CloudWatch Logs log group: /aws/lambda/test-encryption
# CloudWatch Logs log group: /aws/lambda/test-zip
# CloudWatch Logs log group: /aws/lambda/test439_NhsOauthTokenGeneratorLambda
# CloudWatch Logs log group: /aws/lambda/test_build
# CloudWatch Logs log group: /aws/lambda/testbox_ReRegistrationEventHandler
# CloudWatch Logs log group: /aws/lambda/testbox_VirusScannedEventHandler
# CloudWatch Logs log group: /aws/lambda/upload_test
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_PRMT371-app-monitor624651b8
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_delete-app-monitor8ed61235
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_delete1-app-monitor3724fb64
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_delete1-app-monitor3ed510b9
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_delete1-app-monitor5feaeb76
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_delete1-app-monitor8219560e
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_delete2-app-monitor054cfbdf
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_delete2-app-monitorc3e2bdde
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_delete3-app-monitor7acab492
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_mockcis2-app-monitor1b3566b1
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_mockcis2-app-monitor4b88d5a8
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_mockcis2-app-monitore5dda96c
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_ndr-101-app-monitor7160822e
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_ndr-dev-app-monitor12efa574
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_ndr194-app-monitor41840478
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_ndrv-app-monitorb873c128
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_prme16-app-monitordeead498
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_prmt371-app-monitor20679959
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_prmt371-app-monitor63986177
# CloudWatch Logs log group: /aws/vendedlogs/RUMService_test439-app-monitord9255488
# SQS queue: testbox-re-registration
# SQS queue: testbox-re-registration-dlq
# SQS queue: testbox-sensitive-audit
# SQS queue: testbox-sensitive-nems-audit
# CloudWatch Events rule: ndrd_test_lambda_cron
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-back-channel-logout-alarms-topic20240423133031053500000090
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-back-channel-logout-alarms-topic202405291106214451000000a8
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-bulk-upload-metadata-topic2024042313304983350000009e
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-bulk-upload-report-topic2024042313304747190000009c
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-bulk-upload-report-topic202405291106183477000000a2
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-bulk-upload-topic202404231330512862000000a0
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-bulk-upload-topic202405291106195674000000a4
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-create_doc-alarms-topic20240423132826478900000016
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-create_doc-alarms-topic2024042313291097950000004a
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-create_doc_manifest-alarms-topic20240423132826509500000018
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-delete_doc-alarms-topic2024042313282738870000001a
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-feature_flags_alarms-topic2024042313282504770000000e
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-lloyd-george-stitch-topic2024042313282750930000001e
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-login_redirect-alarms-topic2024042313304616230000009a
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-logout-alarms-topic2024042313291439440000004c
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-logout-alarms-topic202404231331461582000000ab
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-logout-alarms-topic202405291106201633000000a6
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-mesh-forwarder-nems-events-sns-topic20240423133038107000000092
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-nems-message-lambda-alarm-topic202404231331576748000000ad
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-nems-message-lambda-alarm-topic202405291106149994000000a0
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-search_doc_references-alarms-topic20240423132826391200000014
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-search_patient_details_alarms-topic2024042313282749880000001c
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-send-feedback-topic202404231331055190000000a7
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-update-upload-state-topic202404231331271104000000a9
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-upload_confirm_result_alarm-topic20240423132825320700000012
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndra-sns-virus_scan_result_alarm-topic20240423132825083700000010
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndrb-sns-logout-alarms-topic20240102110525967000000075
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndrd-sns-lloyd-george-stitch-topic20241125112713587700000020
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndrd-sns-logout-alarms-topic20240102114411300100000075
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndrd-sns-search_doc_references-alarms-topic20241125112715449400000024
# SNS topic: arn:aws:sns:eu-west-2:533825906475:ndrd-sns-search_patient_details_alarms-topic20241125112715446500000022
# CloudWatch alarm: TargetTracking-table/ndr-test_DocumentReferenceMetadata-AlarmHigh-e5310df3-9957-4270-a761-d5a433ae2bd6
# CloudWatch alarm: TargetTracking-table/ndr-test_DocumentReferenceMetadata-AlarmHigh-e550811d-6271-4129-8275-52ad2f9ca1a2
# CloudWatch alarm: TargetTracking-table/ndr-test_DocumentReferenceMetadata-AlarmLow-45619e83-fae4-40ae-965c-2118804e5116
# CloudWatch alarm: TargetTracking-table/ndr-test_DocumentReferenceMetadata-AlarmLow-b5b21c2c-ff7f-4324-9e43-8bff024ccea0
# CloudWatch alarm: TargetTracking-table/ndr-test_DocumentReferenceMetadata-ProvisionedCapacityHigh-2f18eb4c-ba2d-41c8-9b7a-6b8efbc5d20e
# CloudWatch alarm: TargetTracking-table/ndr-test_DocumentReferenceMetadata-ProvisionedCapacityHigh-a553ec52-3463-4629-a2ab-6107a186aefb
# CloudWatch alarm: TargetTracking-table/ndr-test_DocumentReferenceMetadata-ProvisionedCapacityLow-46b2c387-d42e-4c3d-a3f5-36b3990902e5
# CloudWatch alarm: TargetTracking-table/ndr-test_DocumentReferenceMetadata-ProvisionedCapacityLow-58cb41a8-5018-4bcd-8595-d33e1f1c7923
# CloudWatch alarm: TargetTracking-table/ndr-test_LloydGeorgeReferenceMetadata-AlarmHigh-5ec1cb29-9199-40a5-95fb-5355616613a2
# CloudWatch alarm: TargetTracking-table/ndr-test_LloydGeorgeReferenceMetadata-AlarmHigh-bb39ad09-4817-4a8e-a556-177bc54ebaa2
# CloudWatch alarm: TargetTracking-table/ndr-test_LloydGeorgeReferenceMetadata-AlarmLow-0f6e8177-c849-4aee-ab0a-e5b6fa4362d1
# CloudWatch alarm: TargetTracking-table/ndr-test_LloydGeorgeReferenceMetadata-AlarmLow-2e068111-3b37-4877-bbf1-25330266b0be
# CloudWatch alarm: TargetTracking-table/ndr-test_LloydGeorgeReferenceMetadata-ProvisionedCapacityHigh-1ea0265a-f7d6-4e40-b050-160b3fcf4360
# CloudWatch alarm: TargetTracking-table/ndr-test_LloydGeorgeReferenceMetadata-ProvisionedCapacityHigh-cc0f0658-8680-4235-980a-45842f6626ab
# CloudWatch alarm: TargetTracking-table/ndr-test_LloydGeorgeReferenceMetadata-ProvisionedCapacityLow-3f65f0a8-db86-435c-9887-b7bbcd3c2bb3
# CloudWatch alarm: TargetTracking-table/ndr-test_LloydGeorgeReferenceMetadata-ProvisionedCapacityLow-ea3e8861-2437-4661-b7d3-b235c36e9749
# CloudWatch alarm: TargetTracking-table/virus-scanner-terraform-lock-AlarmHigh-5e0ee178-f1ac-4c60-b90d-c745dfb7c4c1
# CloudWatch alarm: TargetTracking-table/virus-scanner-terraform-lock-AlarmHigh-e8ee1b89-5f1d-4991-8c4a-44169f685efb
# CloudWatch alarm: TargetTracking-table/virus-scanner-terraform-lock-AlarmLow-26f43d90-1f34-46f2-9caf-a27ad161bffe
# CloudWatch alarm: TargetTracking-table/virus-scanner-terraform-lock-AlarmLow-b2fa5283-ad82-45c0-8e81-ec5d93f1e74b
# CloudWatch alarm: TargetTracking-table/virus-scanner-terraform-lock-ProvisionedCapacityHigh-353ae9fa-c4c3-49ff-8ee1-69d8a425b8f2
# CloudWatch alarm: TargetTracking-table/virus-scanner-terraform-lock-ProvisionedCapacityHigh-b28bc2e4-b42a-4b54-94ea-f2fdf679c5eb
# CloudWatch alarm: TargetTracking-table/virus-scanner-terraform-lock-ProvisionedCapacityLow-541ab662-a732-4e94-a069-d33d538a2648
# CloudWatch alarm: TargetTracking-table/virus-scanner-terraform-lock-ProvisionedCapacityLow-5c7a4be1-2ebc-4ce0-924a-8ec64527f5f8
# Lambda Layer: mockcis2_reports_lambda_layer
# Lambda Layer: ndr-143_alerting_lambda_layer
# Lambda Layer: ndr-143_core_lambda_layer
# Lambda Layer: ndr-143_data_lambda_layer
# Lambda Layer: ndr-143_reports_lambda_layer
# Lambda Layer: ndr-187_reports_lambda_layer
# Lambda Layer: ndr-198_reports_lambda_layer
# Lambda Layer: ndr-ld_alerting_lambda_layer
# Lambda Layer: ndr-ld_core_lambda_layer
# Lambda Layer: ndr-ld_data_lambda_layer
# Lambda Layer: ndr-ld_reports_lambda_layer
# Lambda Layer: ndr-perf_reports_lambda_layer
# Lambda Layer: ndr-test_core_lambda_layer
# Lambda Layer: ndr-test_data_lambda_layer
# Lambda Layer: ndr164_reports_lambda_layer
# Lambda Layer: ndr188_reports_lambda_layer
# Lambda Layer: ndr210_reports_lambda_layer
# Lambda Layer: ndr73_alerting_lambda_layer
# Lambda Layer: ndr73_core_lambda_layer
# Lambda Layer: ndr73_data_lambda_layer
# Lambda Layer: ndr73_reports_lambda_layer
# Lambda Layer: ndr_alerting_lambda_layer
# Lambda Layer: ndr_core_lambda_layer
# Lambda Layer: ndr_data_lambda_layer
# Lambda Layer: ndr_reports_lambda_layer
# Lambda Layer: ndra_alerting_lambda_layer
# Lambda Layer: ndra_core_lambda_layer
# Lambda Layer: ndra_data_lambda_layer
# Lambda Layer: ndra_reports_lambda_layer
# Lambda Layer: ndradam_alerting_lambda_layer
# Lambda Layer: ndradam_core_lambda_layer
# Lambda Layer: ndradam_data_lambda_layer
# Lambda Layer: ndradam_reports_lambda_layer
# Lambda Layer: ndrb_reports_lambda_layer
# Lambda Layer: ndrbob_reports_lambda_layer
# Lambda Layer: ndrc_alerting_lambda_layer
# Lambda Layer: ndrc_core_lambda_layer
# Lambda Layer: ndrc_data_lambda_layer
# Lambda Layer: ndrc_reports_lambda_layer
# Lambda Layer: ndrclinic_reports_lambda_layer
# Lambda Layer: ndrd_reports_lambda_layer
# Lambda Layer: ndrduncan2_reports_lambda_layer
# Lambda Layer: ndrduncan_alerting_lambda_layer
# Lambda Layer: ndrduncan_core_lambda_layer
# Lambda Layer: ndrduncan_data_lambda_layer
# Lambda Layer: ndrduncan_reports_lambda_layer
# Lambda Layer: ndre_alerting_lambda_layer
# Lambda Layer: ndre_core_lambda_layer
# Lambda Layer: ndre_data_lambda_layer
# Lambda Layer: ndre_reports_lambda_layer
# Lambda Layer: ndrld2_reports_lambda_layer
# Lambda Layer: ndrld_alerting_lambda_layer
# Lambda Layer: ndrld_core_lambda_layer
# Lambda Layer: ndrld_data_lambda_layer
# Lambda Layer: ndrld_reports_lambda_layer
# Lambda Layer: ndrpdf_alerting_lambda_layer
# Lambda Layer: ndrpdf_core_lambda_layer
# Lambda Layer: ndrpdf_data_lambda_layer
# Lambda Layer: ndrpdf_reports_lambda_layer
# Lambda Layer: ndrprme79_reports_lambda_layer
# Lambda Layer: ndrrob_alerting_lambda_layer
# Lambda Layer: ndrrob_core_lambda_layer
# Lambda Layer: ndrrob_data_lambda_layer
# Lambda Layer: ndrrob_reports_lambda_layer
# Lambda Layer: ndrs_alerting_lambda_layer
# Lambda Layer: ndrs_core_lambda_layer
# Lambda Layer: ndrs_data_lambda_layer
# Lambda Layer: ndrs_reports_lambda_layer
# Lambda Layer: ndrsam_alerting_lambda_layer
# Lambda Layer: ndrsam_core_lambda_layer
# Lambda Layer: ndrsam_data_lambda_layer
# Lambda Layer: ndrsam_reports_lambda_layer
# Lambda Layer: ndrv_alerting_lambda_layer
# Lambda Layer: ndrv_core_lambda_layer
# Lambda Layer: ndrv_data_lambda_layer
# Lambda Layer: ndrv_reports_lambda_layer
# Lambda Layer: prm429_alerting_lambda_layer
# Lambda Layer: prm429_core_lambda_layer
# Lambda Layer: prm429_data_lambda_layer
# Lambda Layer: prm429_reports_lambda_layer
# Lambda Layer: prm459_alerting_lambda_layer
# Lambda Layer: prm459_core_lambda_layer
# Lambda Layer: prm459_data_lambda_layer
# Lambda Layer: prm459_reports_lambda_layer
# Lambda Layer: prme-73_alerting_lambda_layer
# Lambda Layer: prme-73_core_lambda_layer
# Lambda Layer: prme-73_data_lambda_layer
# Lambda Layer: prme-73_reports_lambda_layer
# Lambda Layer: prme73_alerting_lambda_layer
# Lambda Layer: prme73_core_lambda_layer
# Lambda Layer: prme73_data_lambda_layer
# Lambda Layer: prme73_reports_lambda_layer
# Lambda Layer: prmt371_reports_lambda_layer
# Lambda Layer: prmt463_alerting_lambda_layer
# Lambda Layer: prmt463_core_lambda_layer
# Lambda Layer: prmt463_data_lambda_layer
# Lambda Layer: prmt463_reports_lambda_layer
# Lambda Layer: prmt466_alerting_lambda_layer
# Lambda Layer: prmt466_core_lambda_layer
# Lambda Layer: prmt466_data_lambda_layer
# Lambda Layer: prmt466_reports_lambda_layer
# Lambda Layer: prmt523_reports_lambda_layer
# Lambda Layer: prmt546_alerting_lambda_layer
# Lambda Layer: prmt546_core_lambda_layer
# Lambda Layer: prmt546_data_lambda_layer
# Lambda Layer: prmt546_reports_lambda_layer
# Lambda Layer: test439_alerting_lambda_layer
# Lambda Layer: test439_reports_lambda_layer
# CloudWatch Dashboard: Spike-463
# CloudWatch Dashboard: Spike-771
# CloudWatch Dashboard: Tracking_Dashboard
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-logout-alarms-topic202404231331461582000000ab:1bcedfdc-b542-47cb-bcd6-cc654116d23a
# SNS Subscription: PendingConfirmation
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrc-sns-delete_doc-alarms-topic20240603085132761800000011:4a7e46f4-19fe-43eb-9148-00f4a6b583b0
# SNS Subscription: PendingConfirmation
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:108148468272:pre-prod-nems-event-processor-re-registrations-sns-topic:79e3524c-e748-4d7c-84db-5bf363727c80
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrc-sns-lloyd-george-stitch-topic20240603085136502300000018:c96aeb34-d599-4b7e-903b-702ef44910bb
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-nhs-oauth-token-generator-topic2025041608504762080000001e:e6804488-a587-46cf-865e-7f2eaf0d2214
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrc-sns-virus_scan_result_alarm-topic2024060308513769330000001d:f7658418-ea02-412a-b357-49d2357d5793
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:CloudStorageSecTopic-w4402se:00a6892c-bf4f-4805-b0e5-b4bff6458dd6
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrc-sns-create_doc_manifest-alarms-topic:0a23afaa-c25e-42ed-8b31-d25447f934fa
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:CloudStorageSecTopic-3k85qxs:15dcd2b4-3961-4453-b2bd-815ee5bd4c8c
# SNS Subscription: PendingConfirmation
# SNS Subscription: PendingConfirmation
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrb-sns-logout-alarms-topic20240102110525967000000075:3305e9a3-fa1b-43ca-9083-1ee35aa73a3b
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrc-sns-feature_flags_alarms-topic2024060308513254050000000f:563b98c9-4556-4928-b3d2-321af71e573a
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:108148468272:pre-prod-nems-event-processor-re-registrations-sns-topic:7a76b56c-e99f-40ba-a9f2-17a8ee3a7fdf
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrc-sns-back-channel-logout-alarms-topic202406030854172853000000a6:87cea53a-6bc6-4fb6-a506-3adb928ede66
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:108148468272:pre-prod-nems-event-processor-re-registrations-sns-topic:eacf0421-e75e-4a6e-99bd-766567a5340d
# SNS Subscription: PendingConfirmation
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-mesh-forwarder-nems-events-sns-topic20240423133038107000000092:fb105cbb-a914-4312-bb62-701e0bfd3c7c
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrc-sns-search_doc_references-alarms-topic20240603085135281200000014:fd4e5486-888b-4403-b028-846c82a20319
# SNS Subscription: PendingConfirmation
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrc-sns-search_patient_details_alarms-topic2024060308513769050000001b:4e3a88d3-acfd-4278-a30c-1c56afd3002b
# SNS Subscription: PendingConfirmation
# SNS Subscription: PendingConfirmation
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-back-channel-logout-alarms-topic20240423133031053500000090:6e60a99e-5064-4580-815b-c728cb529247
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrc-sns-bulk-upload-metadata-topic20240603085403047500000099:7391a7ed-7608-46a5-a56a-6fd23efff88e
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-back-channel-logout-alarms-topic202405291106214451000000a8:952f6191-24b0-4d4f-99ae-0cfa4fe1cb3d
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-delete_doc-alarms-topic2024042313282738870000001a:9f4255b3-f3fb-416f-b027-2514f5073914
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:CloudStorageSecNotificationsTopic-miyho7d:b8905941-57e6-42d4-8766-d06b057b91c3
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrc-sns-bulk-upload-report-topic202406030854159523000000a2:bf252e51-3e29-4378-80e0-6d3c1fd51487
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-bulk-upload-metadata-topic2024042313304983350000009e:c1779034-7d0c-41d3-864f-77eb83329200
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrc-sns-update-upload-state-topic202406030854244546000000aa:d891347e-9dfc-4910-aa8d-52bf9488c49d
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-bulk-upload-topic202404231330512862000000a0:d8f49347-c901-4058-9c5d-f696ebc24a27
# SNS Subscription: PendingConfirmation
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:CloudStorageSecTopic-miyho7d:1466037c-bbf1-4492-82d4-f43d78baf070
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:aws-controltower-SecurityNotifications:279bd69a-01c9-4b45-99f2-7e83a3824d16
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:CloudStorageSecNotificationsTopic-miyho7d:5dc9b42e-ffb5-45f0-9190-62eae6a7d31a
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:CloudStorageSecNotificationsTopic-miyho7d:8ac89d9c-a557-42b3-8f4a-356afe833d26
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-create_doc-alarms-topic2024042313291097950000004a:922e6c4d-b56a-450f-9716-1acc17c66dd8
# SNS Subscription: PendingConfirmation
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndr-test-sns-create_doc-alarms-topic:b7131a4a-a41c-4124-9c62-1980caf6cef5
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-create_doc_manifest-alarms-topic20240423132826509500000018:c2c337be-b49b-4fb6-9a4a-4e70c85d4fb2
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:CloudStorageSecNotificationsTopic-miyho7d:03b1f17d-e4c1-49ef-a3a9-ff0f168d6a74
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:CloudStorageSecTopic-azf2kr0:0d421a0d-f9fe-4a3b-9c85-49f26f2eab4c
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrc-sns-logout-alarms-topic202406030855001968000000ac:2ce91c02-6819-42b3-a6d7-335236939dea
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-lloyd-george-stitch-topic2024042313282750930000001e:3617141d-dbe2-4db1-8740-0f16e8ce366b
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-search_doc_references-alarms-topic20240423132826391200000014:3a79079d-a377-4f29-8635-7f8d8f29fa3a
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-upload_confirm_result_alarm-topic20240423132825320700000012:4c3a6c64-e0d5-4f66-9e9a-d9ff852967f8
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-logout-alarms-topic2024042313291439440000004c:68d17b98-dff9-4aec-af9a-ba6f3d398d4e
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-bulk-upload-report-topic202405291106183477000000a2:6c6d48de-e442-4383-a238-973324ab8a1b
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-bulk-upload-topic202405291106195674000000a4:8c462717-74ba-4413-99a1-8573a5f1958e
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-edge_presign-alarms-topic20250416085109088900000026:9ecf94e5-3b76-43a5-ad71-ee7a183e2a09
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-bulk-upload-report-topic2024042313304747190000009c:bb21d47c-6541-44d3-b099-08708e1016b1
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-update-upload-state-topic202404231331271104000000a9:ed5552d6-28f8-413e-8bd7-912169250351
# SNS Subscription: PendingConfirmation
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-search_patient_details_alarms-topic2024042313282749880000001c:fb6226fa-70b1-4fbc-958c-e6be6f7e5001
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:CloudStorageSecTopic-a6ldvyb:08692c20-8746-4168-8ce2-f96e7002dd1d
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrc-sns-send-feedback-topic202406030854184464000000a8:0d6e634a-713f-4c6f-9a60-232af88cda30
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrd-sns-logout-alarms-topic20240102114411300100000075:0f7223f1-5cda-4de9-b21b-c283017b416b
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-virus_scan_result_alarm-topic20240423132825083700000010:148d711b-bfbb-4379-b448-c7496c218b87
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrc-sns-logout-alarms-topic202406030854167545000000a4:3e9e7d7c-34f5-4e9f-a30f-d28b0ebdd982
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-login_redirect-alarms-topic20250416085237352800000067:42a35545-74f7-42c4-9f47-76f46d240c34
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-login_redirect-alarms-topic2024042313304616230000009a:7527c8ed-5b0e-43ed-9e44-e4e497aafa16
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:CloudStorageSecNotifications-8km0aj3:752d06a2-f004-421c-ae5d-43bcc5791878
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-nems-message-lambda-alarm-topic202404231331576748000000ad:89655799-2807-4f88-a567-dca6234c4952
# SNS Subscription: PendingConfirmation
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrc-sns-create_doc_manifest-alarms-topic2024060308513888010000001f:9c8ddd7f-79a0-4384-9e92-07a0e4cd5873
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-alarms-notification-topic-20250416145731871800000002:a897d4ee-9b2e-4193-89bd-92fa170ac5b3
# SNS Subscription: PendingConfirmation
# SNS Subscription: PendingConfirmation
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrb-sns-search_doc_references-alarms-topic20240102110227323000000010:3d8084f3-8ec5-443e-ba2a-7e62e0f2d978
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:CloudStorageSecNotificationsTopic-azf2kr0:3e281762-2d3b-4b86-a8bd-00c465ee58e9
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-nems-message-lambda-alarm-topic202405291106149994000000a0:4a03e915-2987-466c-89a1-182860b7ad78
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:CloudStorageSecTopic-36ckfco:5cf8026b-6bb9-4cce-935f-626a7844019f
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:CloudStorageSecTopic-69d4kyh:9c95aba9-4270-4d0f-8046-daffcecf7737
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-search_patient_details_alarms-topic20250417075502237800000034:9e5ade1a-7e88-4b30-8f49-c40d649d64c8
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-create_doc-alarms-topic20240423132826478900000016:b50aa31c-35b0-41f1-ae38-db8040c1272f
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:CloudStorageSecTopic-k2xp0tr:b57ba511-4a40-44e2-a302-870c463ca8af
# SNS Subscription: PendingConfirmation
# SNS Subscription: PendingConfirmation
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrc-sns-nems-message-lambda-alarm-topic202406030855077835000000ae:cfa0091e-603e-4283-95b7-bc9b860d904e
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-send-feedback-topic202404231331055190000000a7:d05f9dab-d691-45e0-8fa4-1f52c0b7b96e
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-feature_flags_alarms-topic2024042313282504770000000e:d2aa44ca-1674-42b7-befb-99000ca2a335
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndra-sns-logout-alarms-topic202405291106201633000000a6:e135ac8d-ca3d-4bf6-93ce-2378d4731afb
# SNS Subscription: arn:aws:sns:eu-west-2:533825906475:ndrc-sns-upload_confirm_result_alarm-topic20240603085136503300000019:ec2a2017-dfaa-4c72-ae04-b7c1d8cb3749
