#!/bin/bash

TERRAFORM_WORKSPACE=""
do_delete=false

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color (reset)

function _list_tagged_resources() {
  local workspace=$1

  if [ -z "$workspace" ]; then
    resources=$(aws resourcegroupstaggingapi get-resources --output json)
  else
    resources=$(aws resourcegroupstaggingapi get-resources \
      --tag-filters Key=Workspace,Values="$workspace" \
      --output json)
  fi

  # Extract resource ARNs
  resource_arns=$(echo "$resources" | jq -r '.ResourceTagMappingList[]?.ResourceARN')

  if [ -z "$resource_arns" ]; then
    echo -e "${RED}No tagged resources found.${NC}"
    return 0
  fi

  # Loop and display
  for arn in $resource_arns; do
    echo -e "${GREEN}Tagged resource: ${arn} ${NC}"
  done
}

function _list_lambdas() {
  local workspace=$1

  if [ -n "$workspace" ]; then
    FUNCTIONS=$(aws lambda list-functions | jq -r --arg SUBSTRING1 "${workspace}_" --arg SUBSTRING2 "${workspace}-" '.Functions[] | select((.FunctionName | contains($SUBSTRING1)) or (.FunctionName | contains($SUBSTRING2))) | .FunctionName')
  else
    FUNCTIONS=$(aws lambda list-functions | jq -r '.Functions[].FunctionName')
  fi

  if [ -z "$FUNCTIONS" ]; then
    echo -e "${RED}No Lambda functions found.${NC}"
    return 0
  fi

  for FUNCTION_NAME in $FUNCTIONS; do
    echo -e "${GREEN}Lambda function: ${FUNCTION_NAME} ${NC}"
  done
}

function _delete_lambdas() {
  local workspace=$1

  if [ -n "$workspace" ]; then
    FUNCTIONS=$(aws lambda list-functions | jq -r --arg SUBSTRING1 "${workspace}_" --arg SUBSTRING2 "${workspace}-" '.Functions[] | select((.FunctionName | contains($SUBSTRING1)) or (.FunctionName | contains($SUBSTRING2))) | .FunctionName')

    if [ -z "$FUNCTIONS" ]; then
      echo -e "${RED}No Lambda functions found.${NC}"
      return 0
    fi

    for FUNCTION_NAME in $FUNCTIONS; do
      echo -e "${GREEN}Deleting Lambda function: ${FUNCTION_NAME} ${NC}"
      aws lambda delete-function --function-name $FUNCTION_NAME
    done
  fi
}

function _list_all_kms() {
  local workspace=$1

  if [ -n "$workspace" ]; then
    ALIASES=$(aws kms list-aliases | jq -r --arg SUBSTRING1 "${workspace}_" --arg SUBSTRING2 "${workspace}-" '.Aliases[] | select((.AliasName | contains($SUBSTRING1)) or (.AliasName | contains($SUBSTRING2))) | .AliasName')
  else
    ALIASES=$(aws kms list-aliases | jq -r '.Aliases[].AliasName')
  fi

  if [ -z "$ALIASES" ]; then
    echo -e "${RED}No KMS aliases found.${NC}"
    return 0
  fi

  for ALIAS in $ALIASES; do
    # Get the KMS key ID associated with the alias
    KEY_ID=$(aws kms describe-key --key-id "$ALIAS" 2>/dev/null | jq -r '.KeyMetadata.KeyId')

    echo -e "${GREEN}KMS alias: ${ALIAS} ${NC}"
    if [ -n "$KEY_ID" ]; then
      echo -e "${GREEN}KMS Key ID: ${KEY_ID} ${NC}"
    else
      echo -e "${RED}Warning: Could not resolve key ID for alias ${ALIAS} ${NC}"
    fi
  done
}

function _list_log_groups() {
  local workspace=$1
  local log_groups

  if [ -n "$workspace" ]; then
    log_groups=$(aws logs describe-log-groups | jq -r --arg substring1 "${workspace}-" --arg substring2 "${workspace}_" '.logGroups[] | select((.logGroupName | contains($substring1)) or (.logGroupName | contains($substring2))) | .logGroupName')
  else
    log_groups=$(aws logs describe-log-groups | jq -r '.logGroups[].logGroupName')
  fi

  if [ -z "$log_groups" ]; then
    echo -e "${RED}No CloudWatch Logs log groups found.${NC}"
    return 0
  fi

  for log_group in $log_groups; do
    echo -e "${GREEN}CloudWatch Logs log group: ${log_group} ${NC}"
  done
}

function _delete_log_groups() {
  local workspace=$1
  local log_groups

  # List all log groups and filter those containing the specified substring
  if [ -n "$workspace" ]; then
    log_groups=$(aws logs describe-log-groups | jq -r --arg substring1 "${workspace}-" --arg substring2 "${workspace}_" '.logGroups[] | select((.logGroupName | contains($substring1)) or (.logGroupName | contains($substring2))) | .logGroupName')

    # Check if any log groups were found
    if [ -z "$log_groups" ]; then
      echo -e "${RED}No CloudWatch Logs log groups found containing the substring: $workspace ${NC}"
      return 0
    fi

    # Loop through each log group and delete it
    for log_group in $log_groups; do
      echo -e "${GREEN}Deleting CloudWatch Logs log group: ${log_group} ${NC}"
      aws logs delete-log-group --log-group-name "$log_group"
    done
  fi
}

function _list_dynamo_tables() {
  local workspace=$1
  local tables

  if [ -n "$workspace" ]; then
    tables=$(aws dynamodb list-tables | jq -r --arg substring1 "${workspace}-" --arg substring2 "${workspace}_" '.TableNames[] | select((. | contains($substring1)) or (. | contains($substring2)))')
  else
    tables=$(aws dynamodb list-tables | jq -r '.TableNames[]')
  fi

  if [ -z "$tables" ]; then
    echo -e "${RED}No DynamoDB tables found.${NC}"
    return 0
  fi

  for table in $tables; do
    echo -e "${GREEN}DynamoDB table: ${table} ${NC}"
  done
}

function _list_s3_buckets() {
  local workspace=$1
  local buckets

  if [ -n "$workspace" ]; then
    buckets=$(aws s3api list-buckets | jq -r '.Buckets[].Name' | grep -E -- "${workspace}[_-]")
  else
    buckets=$(aws s3api list-buckets | jq -r '.Buckets[].Name')
  fi

  if [ -z "$buckets" ]; then
    echo -e "${RED}No S3 buckets found.${NC}"
    return 0
  fi

  for bucket in $buckets; do
    echo -e "${GREEN}S3 bucket: ${bucket} ${NC}"
  done
}

function _list_api_gateway() {
  local workspace=$1
  local apis
  local domains

  if [ -n "$workspace" ]; then
    apis=$(aws apigateway get-rest-apis --output json | jq -r --arg SUBSTRING1 "${workspace}-" --arg SUBSTRING2 "${workspace}_" '.items[] | select((.name | contains($SUBSTRING1)) or (.name | contains($SUBSTRING2))) | .id')
  else
    apis=$(aws apigateway get-rest-apis --output json | jq -r '.items[].id')
  fi

  if [ -z "$apis" ]; then
    echo -e "${RED}No API Gateway resources found.${NC}"
  else
    for api_id in $apis; do
      echo -e "${GREEN}API Gateway: ${api_id} ${NC}"
    done
  fi

  domains=$(aws apigateway get-domain-names --output json | jq -r '.items[].domainName')
  if [ -n "$workspace" ]; then
    for domain in $domains; do
      if [[ $domain == *"-${workspace}."* ]]; then
        echo -e "${GREEN}Domain: ${domain} ${NC}"
      fi
    done
  else
    for domain in $domains; do
      echo -e "${GREEN}Domain: ${domain} ${NC}"
    done
  fi
}

function _list_ssm_parameters() {
  local workspace=$1
  local params

  if [ -n "$workspace" ]; then
    params=$(aws ssm describe-parameters --output json | jq -r --arg SUBSTRING "/${workspace}/" '.Parameters[] | select(.Name | contains($SUBSTRING)) | .Name')
  else
    params=$(aws ssm describe-parameters --output json | jq -r '.Parameters[].Name')
  fi

  if [ -z "$params" ]; then
    echo -e "${RED}No SSM Parameters found.${NC}"
    return 0
  fi

  for param in $params; do
    echo -e "${GREEN}SSM Parameter: ${param} ${NC}"
  done
}

function _delete_ssm_parameters() {
  local workspace=$1
  local params

  if [ -n "$workspace" ]; then
    params=$(aws ssm describe-parameters --output json | jq -r --arg SUBSTRING "/${workspace}/" '.Parameters[] | select(.Name | contains($SUBSTRING)) | .Name')

    if [ -z "$params" ]; then
      echo -e "${RED}No SSM Parameters found.${NC}"
      return 0
    fi

    for param in $params; do
      echo -e "${GREEN}Deleting SSM Parameter: ${param} ${NC}"
      aws ssm delete-parameter --name $param
    done
  fi
}

function _list_secrets() {
  local workspace=$1
  local secrets

  if [ -n "$workspace" ]; then
    secrets=$(aws secretsmanager list-secrets | jq -r --arg substring "$workspace" '.SecretList[] | select(.Name | contains($substring)) | .ARN')
  else
    secrets=$(aws secretsmanager list-secrets | jq -r '.SecretList[].ARN')
  fi

  if [ -z "$secrets" ]; then
    echo -e "${RED}No Secrets Manager secrets found.${NC}"
    return 0
  fi

  for secret in $secrets; do
    echo -e "${GREEN}Secrets Manager secret: ${secret} ${NC}"
  done
}

function _delete_secrets() {
  local workspace=$1
  local secrets

  if [ -n "$workspace" ]; then
    secrets=$(aws secretsmanager list-secrets | jq -r --arg substring "$workspace" '.SecretList[] | select(.Name | contains($substring)) | .ARN')

    if [ -z "$secrets" ]; then
      echo -e "${RED}No Secrets Manager secrets found.${NC}"
      return 0
    fi

    for secret in $secrets; do
      echo -e "${GREEN}Deleting Secrets Manager: ${secret} ${NC}"
      aws secretsmanager delete-secret --secret-id $secret --force-delete-without-recovery
    done
  fi
}

function _list_iam() {
  local workspace=$1
  local roles policies

  if [ -n "$workspace" ]; then
    roles=$(aws iam list-roles --output json | jq -r --arg SUBSTRING1 "${workspace}_" --arg SUBSTRING2 "${workspace}-" '.Roles[] | select((.RoleName | contains($SUBSTRING1)) or (.RoleName | contains($SUBSTRING2))) | .RoleName')
    policies=$(aws iam list-policies --scope Local --output json | jq -r --arg SUBSTRING1 "${workspace}_" --arg SUBSTRING2 "${workspace}-" '.Policies[] | select((.PolicyName | contains($SUBSTRING1)) or (.PolicyName | contains($SUBSTRING2))) | .Arn')
  else
    roles=$(aws iam list-roles --output json | jq -r '.Roles[].RoleName')
    policies=$(aws iam list-policies --scope Local --output json | jq -r '.Policies[].Arn')
  fi

  if [ -z "$roles" ]; then
    echo -e "${RED}No IAM roles found.${NC}"
  else
    for role in $roles; do
      echo -e "${GREEN}IAM role: ${role} ${NC}"
    done
  fi

  if [ -z "$policies" ]; then
    echo -e "${RED}No IAM policies found.${NC}"
  else
    for policy_arn in $policies; do
      echo -e "${GREEN}IAM policy: ${policy_arn} ${NC}"
    done
  fi
}

function _delete_iam() {
  local workspace=$1
  local roles policies

  if [ -n "$workspace" ]; then
    roles=$(aws iam list-roles --output json | jq -r --arg SUBSTRING1 "${workspace}_" --arg SUBSTRING2 "${workspace}-" '.Roles[] | select((.RoleName | contains($SUBSTRING1)) or (.RoleName | contains($SUBSTRING2))) | .RoleName')
    policies=$(aws iam list-policies --scope Local --output json | jq -r --arg SUBSTRING1 "${workspace}_" --arg SUBSTRING2 "${workspace}-" '.Policies[] | select((.PolicyName | contains($SUBSTRING1)) or (.PolicyName | contains($SUBSTRING2))) | .Arn')

    if [ -z "$roles" ]; then
      echo -e "${RED}No IAM roles found.${NC}"
      return 0
    fi

    if [ -z "$policies" ]; then
      echo -e "${RED}No IAM policies found.${NC}"
    else
      for policy_arn in $policies; do
        echo -e "${GREEN}Detaching and Deleting IAM policy: ${policy_arn} ${NC}"
        aws iam detach-role-policy --role-name MyRole --policy-arn $policy_arn
        aws iam delete-policy --policy-arn $policy_arn
      done
    fi

    for role in $roles; do
      echo -e "${GREEN}Deleting IAM role: ${role} ${NC}"
      inline_policies=$(aws iam list-role-policies --role-name "$role" --query "PolicyNames" --output text)
      if [[ -n "$inline_policies" ]]; then
        for pol in $inline_policies; do
          echo -e "${GREEN} - Deleting inline policy: $pol ${NC}"
          aws iam delete-role-policy --role-name "$role" --policy-name "$pol"
        done
      fi

      managed_policies=$(aws iam list-attached-role-policies --role-name "$role" --query "AttachedPolicies[].PolicyArn" --output text)
      if [[ -n "$managed_policies" ]]; then
        for polarn in $managed_policies; do
          echo -e "${GREEN} - Detaching managed policy: $polarn ${NC}"
          aws iam detach-role-policy --role-name "$role" --policy-arn "$polarn"
        done
      fi

      profiles=$(aws iam list-instance-profiles-for-role --role-name "$role" --query "InstanceProfiles[].InstanceProfileName" --output text)
      if [[ -n "$profiles" ]]; then
        for profile in $profiles; do
          echo -e "${GREEN} - Removing role from instance profile: $profile ${NC}"
          aws iam remove-role-from-instance-profile --instance-profile-name "$profile" --role-name "$role"
        done
      fi

      echo -e "${GREEN} - Deleting role: $role ${NC}"
      aws iam delete-role --role-name "$role"
    done
  fi
}

function _list_firehose_delivery_streams() {
  local workspace=$1
  local streams

  if [ -n "$workspace" ]; then
    streams=$(aws firehose list-delivery-streams --output json | jq -r --arg SUBSTRING "$workspace" '.DeliveryStreamNames[] | select(contains($SUBSTRING))')
  else
    streams=$(aws firehose list-delivery-streams --output json | jq -r '.DeliveryStreamNames[]')
  fi

  if [ -z "$streams" ]; then
    echo -e "${RED}No Kinesis Data Firehose delivery streams found${workspace:+ containing the substring: $workspace} ${NC}"
    return 0
  fi

  for stream in $streams; do
    echo -e "${GREEN}Firehose delivery stream: ${stream} ${NC}"
  done
}

function _list_sqs_queues() {
  local workspace=$1
  local queues

  if [ -n "$workspace" ]; then
    queues=$(aws sqs list-queues --output json | jq -r --arg SUBSTRING1 "${workspace}-" --arg SUBSTRING2 "${workspace}_" '.QueueUrls[] | select(contains($SUBSTRING1) or contains($SUBSTRING1))')
  else
    queues=$(aws sqs list-queues --output json | jq -r '.QueueUrls[]')
  fi

  if [ -z "$queues" ]; then
    echo -e "${RED}No SQS queues found${workspace:+ containing the substring: $workspace} ${NC}"
    return 0
  fi

  for queue_url in $queues; do
    queue_name=$(basename "$queue_url")
    echo -e "${GREEN}SQS queue: ${queue_name} ${NC}"
  done
}

function _list_step_functions() {
  local workspace=$1
  local state_machines

  if [ -n "$workspace" ]; then
    state_machines=$(aws stepfunctions list-state-machines --output json | jq -r --arg SUBSTRING "$workspace" '.stateMachines[] | select(.name | contains($SUBSTRING)) | .stateMachineArn')
  else
    state_machines=$(aws stepfunctions list-state-machines --output json | jq -r '.stateMachines[].stateMachineArn')
  fi

  if [ -z "$state_machines" ]; then
    echo -e "${RED}No Step Functions found${workspace:+ containing the substring: $workspace} ${NC}"
    return 0
  fi

  for state_machine_arn in $state_machines; do
    state_machine_name=$(basename "$state_machine_arn")
    echo -e "${GREEN}Step Function: ${state_machine_name} ${NC}"
  done
}

function _list_cloudwatch_events_rules() {
  local workspace=$1
  local rules

  if [ -n "$workspace" ]; then
    rules=$(aws events list-rules --output json | jq -r --arg SUBSTRING1 "${workspace}-" --arg SUBSTRING2 "${workspace}_" '.Rules[] | select((.Name | contains($SUBSTRING1)) or (.Name | contains($SUBSTRING2))) | .Name')
  else
    rules=$(aws events list-rules --output json | jq -r '.Rules[].Name')
  fi

  if [ -z "$rules" ]; then
    echo -e "${RED}No CloudWatch Events rules found${workspace:+ containing the substring: $workspace} ${NC}"
    return 0
  fi

  for rule_name in $rules; do

    targets=$(aws events list-targets-by-rule --rule "$rule_name" --output json | jq -r '.Targets[].Id')

    if [ -z "$targets" ]; then
      echo -e "${RED}No targets found for rule: ${rule_name} ${NC}"
    else
      for target_id in $targets; do
        echo -e "${GREEN}Target ${target_id} from rule: ${rule_name} ${NC}"
      done
    fi
  done
}

function _list_resource_groups() {
  local workspace=$1
  local resource_groups

  if [ -n "$workspace" ]; then
    resource_groups=$(aws resource-groups list-groups --output json | jq -r --arg SUBSTRING1 "${workspace}-" --arg SUBSTRING2 "${workspace}_" '.GroupIdentifiers[] | select((.GroupArn | contains($SUBSTRING1)) or (.GroupArn | contains($SUBSTRING1))) | .GroupName')
  else
    resource_groups=$(aws resource-groups list-groups --output json | jq -r '.GroupIdentifiers[].GroupName')
  fi

  if [ -z "$resource_groups" ]; then
    echo -e "${RED}No Resource Groups found${workspace:+ containing the substring: $workspace} ${NC}"
    return 0
  fi

  for group_name in $resource_groups; do
    echo -e "${GREEN}Resource Group: ${group_name} ${NC}"
  done
}

function _delete_resource_groups() {
  local workspace=$1
  local resource_groups

  if [ -n "$workspace" ]; then
    resource_groups=$(aws resource-groups list-groups --output json | jq -r --arg SUBSTRING1 "${workspace}-" --arg SUBSTRING2 "${workspace}_" '.GroupIdentifiers[] | select((.GroupArn | contains($SUBSTRING1)) or (.GroupArn | contains($SUBSTRING1))) | .GroupName')

    if [ -z "$resource_groups" ]; then
      echo -e "${RED}No Resource Groups found${workspace:+ containing the substring: $workspace} ${NC}"
      return 0
    fi

    for group_name in $resource_groups; do
      echo -e "${GREEN}Resource Group: ${group_name} ${NC}"
      aws resource-groups delete-group --group-name $group_name
    done
  fi
}

function _list_backup_vaults() {
  local workspace=$1
  local vaults

  if [ -n "$workspace" ]; then
    vaults=$(aws backup list-backup-vaults --output json | jq -r --arg SUBSTRING "${workspace}_" '.BackupVaultList[] | select(.BackupVaultName | contains($SUBSTRING)) | .BackupVaultName')
  else
    vaults=$(aws backup list-backup-vaults --output json | jq -r '.BackupVaultList[].BackupVaultName')
  fi

  if [ -z "$vaults" ]; then
    echo -e "${RED}No Backup Vaults found${workspace:+ containing the substring: $workspace} ${NC}"
    return 0
  fi

  for vault_name in $vaults; do
    echo -e "${GREEN}Backup Vault: ${vault_name} ${NC}"
  done
}

function _list_ecr_repositories() {
  local workspace=$1
  local repos

  if [ -n "$workspace" ]; then
    repos=$(aws ecr describe-repositories --output json | jq -r --arg SUBSTRING "${workspace}-" '.repositories[] | select(.repositoryName | contains($SUBSTRING)) | .repositoryName')
  else
    repos=$(aws ecr describe-repositories --output json | jq -r '.repositories[].repositoryName')
  fi

  if [ -z "$repos" ]; then
    echo -e "${RED}No ECR repositories found${workspace:+ containing the substring: $workspace} ${NC}"
    return 0
  fi

  for repo in $repos; do
    echo -e "${GREEN}ECR repository: ${repo} ${NC}"
  done
}

function _list_ecs_clusters() {
  local workspace=$1
  local clusters

  if [ -n "$workspace" ]; then
    clusters=$(aws ecs list-clusters --output json | jq -r --arg SUBSTRING "${workspace}-" '.clusterArns[] | select(contains($SUBSTRING))')
  else
    clusters=$(aws ecs list-clusters --output json | jq -r '.clusterArns[]')
  fi

  if [ -z "$clusters" ]; then
    echo -e "${RED}No ECS clusters found${workspace:+ containing the substring: $workspace} ${NC}"
    return 0
  fi

  for cluster_arn in $clusters; do
    cluster_name=$(basename "$cluster_arn")
    echo -e "${GREEN}ECS cluster: ${cluster_name} ${NC}"
  done
}

function _list_sns_topics() {
  local workspace=$1
  local topics

  if [ -n "$workspace" ]; then
    topics=$(aws sns list-topics --output json | jq -r --arg SUBSTRING "${workspace}-" '.Topics[] | select(.TopicArn | contains($SUBSTRING)) | .TopicArn')
  else
    topics=$(aws sns list-topics --output json | jq -r '.Topics[].TopicArn')
  fi

  if [ -z "$topics" ]; then
    echo -e "${RED}No SNS topics found${workspace:+ containing the substring: $workspace} ${NC}"
    return 0
  fi

  for topic_arn in $topics; do
    topic_name=$(basename "$topic_arn")
    echo -e "${GREEN}SNS topic: ${topic_name} ${NC}"
  done
}

function _delete_sns_topics() {
  local workspace=$1
  local topics

  if [ -n "$workspace" ]; then
    topics=$(aws sns list-topics --output json | jq -r --arg SUBSTRING "${workspace}-" '.Topics[] | select(.TopicArn | contains($SUBSTRING)) | .TopicArn')

    if [ -z "$topics" ]; then
      echo -e "${RED}No SNS topics found containing the substring: $workspace ${NC}"
      return 0
    fi

    for topic_arn in $topics; do
      topic_name=$(basename "$topic_arn")
      echo -e "${GREEN}Deleting SNS topic: ${topic_name} ${NC}"
      aws sns delete-topic --topic-arn $topic_name
    done
  fi
}

function _list_route53_hosted_zones() {
  local workspace=$1
  local zones

  if [ -n "$workspace" ]; then
    zones=$(aws route53 list-hosted-zones --output json | jq -r --arg SUBSTRING "$workspace" '.HostedZones[] | select(.Name | contains($SUBSTRING)) | .Name')
  else
    zones=$(aws route53 list-hosted-zones --output json | jq -r '.HostedZones[].Name')
  fi

  if [ -z "$zones" ]; then
    echo -e "${RED}No Route 53 hosted zones found${workspace:+ containing the substring: $workspace} ${NC}"
    return 0
  fi

  for zone in $zones; do
    echo -e "${GREEN}Route 53 hosted zone: ${zone} ${NC}"
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
    echo -e "${RED}No SES identities found${SUBSTRING:+ containing the substring: $SUBSTRING} ${NC}"
    return 0
  fi

  for identity in $identities; do
    echo -e "${GREEN}SES identity: ${identity} ${NC}"
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
    echo -e "${RED}No VPCs found${SUBSTRING:+ containing the substring: $SUBSTRING} ${NC}"
    return 0
  fi

  for vpc in $vpcs; do
    echo -e "${GREEN}VPC: ${vpc} ${NC}"
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
    echo -e "${RED}No subnets found${SUBSTRING:+ containing the substring: $SUBSTRING} ${NC}"
    return 0
  fi

  for subnet in $subnets; do
    echo -e "${GREEN}Subnet: ${subnet} ${NC}"
  done
}

function _list_wafv2_web_acls() {
  local workspace=$1
  local filter="."

  if [ -n "$workspace" ]; then
    filter="select(.Name | contains(\"$workspace\"))"
  fi

  regional_acls=$(aws wafv2 list-web-acls --scope REGIONAL --output json | jq -r ".WebACLs[] | $filter | .Name")

  if [ -z "$regional_acls" ]; then
    echo -e "${RED}No REGIONAL Web ACLs found${workspace:+ matching \"$workspace\"} ${NC}"
  else
    for acl in $regional_acls; do
      echo -e "${GREEN}REGIONAL Web ACL: ${acl} ${NC}"
    done
  fi

  cloudfront_acls=$(aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1 --output json | jq -r ".WebACLs[] | $filter | .Name")

  if [ -z "$cloudfront_acls" ]; then
    echo -e "${RED}No CLOUDFRONT Web ACLs found${workspace:+ matching \"$workspace\"} ${NC}"
  else
    for acl in $cloudfront_acls; do
      echo -e "${GREEN}CLOUDFRONT Web ACL: ${acl} ${NC}"
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
    echo -e "${RED}No CloudFront distributions found${SUBSTRING:+ containing the substring: $SUBSTRING} ${NC}"
    return 0
  fi

  for dist in $dists; do
    echo -e "${GREEN}CloudFront distribution: ${dist} ${NC}"
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
    echo -e "${RED}No CloudWatch metrics found${SUBSTRING:+ containing the substring: $SUBSTRING} ${NC}"
    return 0
  fi

  for metric in $metrics; do
    echo -e "${GREEN}CloudWatch metric: ${metric} ${NC}"
  done
}

function _list_cloudwatch_alarms() {
  local workspace=$1
  SUBSTRING="$workspace"

  if [ -z "$SUBSTRING" ]; then
    alarms=$(aws cloudwatch describe-alarms --output json | jq -r '.MetricAlarms[].AlarmName')
  else
    alarms=$(aws cloudwatch describe-alarms --output json | jq -r --arg SUBSTRING1 "${SUBSTRING}-" --arg SUBSTRING2 "${SUBSTRING}_" '.MetricAlarms[] | select((.AlarmName | contains($SUBSTRING1)) or (.AlarmName | contains($SUBSTRING2))) | .AlarmName')
  fi

  if [ -z "$alarms" ]; then
    echo -e "${RED}No CloudWatch alarms found${SUBSTRING:+ containing the substring: $SUBSTRING} ${NC}"
    return 0
  fi

  for alarm in $alarms; do
    echo -e "${GREEN}CloudWatch alarm: ${alarm} ${NC}"
  done
}

function _delete_cloudwatch_alarms() {
  local workspace=$1

  if [ -n "$workspace" ]; then
    alarms=$(aws cloudwatch describe-alarms --output json | jq -r --arg SUBSTRING1 "${SUBSTRING}-" --arg SUBSTRING2 "${SUBSTRING}_" '.MetricAlarms[] | select((.AlarmName | contains($SUBSTRING1)) or (.AlarmName | contains($SUBSTRING2))) | .AlarmName')

    if [ -z "$alarms" ]; then
      echo -e "${RED}No CloudWatch alarms containing the substring: ${workspace} ${NC}"
      return 0
    fi

    echo -e "${GREEN}Deleting the following CloudWatch alarms:"
    for alarm in $alarms; do
      echo "$alarm"
    done
    echo -e " ${NC}"
    aws cloudwatch delete-alarms --alarm-names $alarms
  fi
}

function _list_appconfig() {
  local workspace=$1
  SUBSTRING="$workspace"

  if [ -z "$SUBSTRING" ]; then
    apps=$(aws appconfig list-applications --output json | jq -r '.Items[].Name')
  else
    apps=$(aws appconfig list-applications --output json | jq -r --arg SUBSTRING "RepositoryConfiguration-${SUBSTRING}" '.Items[] | select(.Name == $SUBSTRING) | .Name')
  fi

  if [ -z "$apps" ]; then
    echo -e "${RED}No AppConfig applications found${SUBSTRING:+ containing the substring: $SUBSTRING} ${NC}"
    return 0
  fi

  for app in $apps; do
    echo -e "${GREEN}AppConfig application: ${app} ${NC}"
  done
}

function _list_lambda_layers() {
  local workspace=$1
  local layers=$(aws lambda list-layers --output json)

  if [ -n "$workspace" ]; then
    layers=$(echo "$layers" | jq -r --arg SUBSTRING1 "${workspace}_" --arg SUBSTRING2 "${workspace}-" '.Layers[] | select((.LayerName | contains($SUBSTRING1)) or (.LayerName | contains($SUBSTRING2))) | .LayerName')
  else
    layers=$(echo "$layers" | jq -r '.Layers[] | .LayerName')
  fi

  [ -z "$layers" ] && echo -e "${RED}No Lambda Layers found.${NC}" && return 0

  for layer in $layers; do
    echo -e "${GREEN}Lambda Layer: ${layer} ${NC}"
  done
}

function _delete_lambda_layers() {
  local workspace=$1
  local layers=$(aws lambda list-layers --output json)

  if [ -n "$workspace" ]; then
    layers=$(echo "$layers" | jq -r --arg SUBSTRING1 "${workspace}_" --arg SUBSTRING2 "${workspace}-" '.Layers[] | select((.LayerName | contains($SUBSTRING1)) or (.LayerName | contains($SUBSTRING2))) | .LayerName')

    [ -z "$layers" ] && echo -e "${RED}No Lambda Layers found containing substring: $workspace ${NC}" && return 0

    for layer in $layers; do
      versions=$(aws lambda list-layer-versions --layer-name "$layer" --output json | jq -r '.LayerVersions[].Version')
      for v in $versions; do
        echo -e "${GREEN}Deleting ${layer} version ${v} ${NC}"
        aws lambda delete-layer-version --layer-name "$layer" --version-number "$v"
      done
    done
  fi
}

function _list_cloudwatch_dashboards() {
  local workspace=$1
  local dashboards=$(aws cloudwatch list-dashboards --output json)

  if [ -n "$workspace" ]; then
    dashboards=$(echo "$dashboards" | jq -r --arg SUBSTRING "$workspace" '.DashboardEntries[] | select(.DashboardName | contains($SUBSTRING)) | .DashboardName')
  else
    dashboards=$(echo "$dashboards" | jq -r '.DashboardEntries[] | .DashboardName')
  fi

  [ -z "$dashboards" ] && echo -e "${RED}No CloudWatch Dashboards found.${NC}" && return 0

  for dashboard in $dashboards; do
    echo -e "${GREEN}CloudWatch Dashboard: ${dashboard} ${NC}"
  done
}

function _delete_cloudwatch_dashboards() {
  local workspace=$1
  if [ -z "$workspace" ]; then
    echo -e "${RED}Error: Workspace substring must be provided. Refusing to delete all dashboards.${NC}"
    return 1
  fi

  local dashboards=$(aws cloudwatch list-dashboards --output json)
  dashboards=$(echo "$dashboards" | jq -r --arg SUBSTRING "$workspace" '.DashboardEntries[] | select(.DashboardName | contains($SUBSTRING)) | .DashboardName')

  [ -z "$dashboards" ] && echo -e "${RED}No CloudWatch Dashboards found for deletion.${NC}" && return 0

  echo -e "${GREEN}Deleting the following CloudWatch Dashboards:"
  for dashboard in $dashboards; do
    echo -e "$dashboard"
  done
  echo -e " ${NC}"
  aws cloudwatch delete-dashboards --dashboard-names $dashboards
}

function _list_iam_instance_profiles() {
  local workspace=$1
  local profiles=$(aws iam list-instance-profiles --output json)

  if [ -n "$workspace" ]; then
    profiles=$(echo "$profiles" | jq -r --arg SUBSTRING "$workspace" '.InstanceProfiles[] | select(.InstanceProfileName | contains($SUBSTRING)) | .InstanceProfileName')
  else
    profiles=$(echo "$profiles" | jq -r '.InstanceProfiles[] | .InstanceProfileName')
  fi

  [ -z "$profiles" ] && echo -e "${RED}No IAM Instance Profiles found.${NC}" && return 0

  for profile in $profiles; do
    echo -e "${GREEN}IAM Instance Profile: ${profile} ${NC}"
  done
}

function _list_vpc_endpoints() {
  local workspace=$1
  local endpoints=$(aws ec2 describe-vpc-endpoints --output json)
  if [ -n "$workspace" ]; then
    endpoints=$(echo "$endpoints" | jq -r --arg SUBSTRING "$workspace" '.VpcEndpoints[] | select((.VpcEndpointId   | contains($SUBSTRING)) or (.ServiceName     | contains($SUBSTRING)) or ((.Tags[]? | .Value) // "" | contains($SUBSTRING))) | .VpcEndpointId')
  else
    endpoints=$(echo "$endpoints" | jq -r '.VpcEndpoints[] | .VpcEndpointId')
  fi

  [ -z "$endpoints" ] && echo -e "${RED}No VPC Endpoints found.${NC}" && return 0

  for endpoint in $endpoints; do
    echo -e "${GREEN}VPC Endpoint: ${endpoint} ${NC}"
  done
}

function _list_efs_file_systems() {
  local workspace=$1
  local filesystems=$(aws efs describe-file-systems --output json)

  if [ -n "$workspace" ]; then
    filesystems=$(echo "$filesystems" | jq -r --arg SUBSTRING "$workspace" '.FileSystems[] | select(.Name | contains($SUBSTRING) or .FileSystemId | contains($SUBSTRING)) | .FileSystemId')
  else
    filesystems=$(echo "$filesystems" | jq -r '.FileSystems[] | .FileSystemId')
  fi

  [ -z "$filesystems" ] && echo -e "${RED}No EFS File Systems found.${NC}" && return 0

  for fs in $filesystems; do
    echo -e "${GREEN}EFS File System: ${fs} ${NC}"
  done
}

function _list_elbs() {
  local workspace=$1
  local elbs=$(aws elbv2 describe-load-balancers --output json)

  if [ -n "$workspace" ]; then
    elbs=$(echo "$elbs" | jq -r --arg SUBSTRING1 "${workspace}_" --arg SUBSTRING2 "${workspace}-" '.LoadBalancers[] | select((.LoadBalancerName | contains($SUBSTRING1)) or (.LoadBalancerName | contains($SUBSTRING2))) | .LoadBalancerName')
  else
    elbs=$(echo "$elbs" | jq -r '.LoadBalancers[] | .LoadBalancerName')
  fi

  [ -z "$elbs" ] && echo -e "${RED}No Elastic Load Balancers found.${NC}" && return 0

  for elb in $elbs; do
    echo -e "${GREEN}Elastic Load Balancer: ${elb} ${NC}"
  done
}

function _list_target_groups() {
  local workspace=$1
  local tgs=$(aws elbv2 describe-target-groups --output json)

  if [ -n "$workspace" ]; then
    tgs=$(echo "$tgs" | jq -r --arg SUBSTRING1 "${workspace}_" --arg SUBSTRING2 "${workspace}-" '.TargetGroups[] | select((.TargetGroupName | contains($SUBSTRING1)) or (.TargetGroupName | contains($SUBSTRING2))) | .TargetGroupName')
  else
    tgs=$(echo "$tgs" | jq -r '.TargetGroups[] | .TargetGroupName')
  fi

  [ -z "$tgs" ] && echo -e "${RED}No Target Groups found.${NC}" && return 0

  for tg in $tgs; do
    echo -e "${GREEN}Target Group: ${tg} ${NC}"
  done
}

function _list_cognito_pools() {
  local workspace=$1

  user_pools=$(aws cognito-idp list-user-pools --max-results 60 --output json)

  if [ -n "$workspace" ]; then
    user_pools=$(echo "$user_pools" | jq -r --arg SUBSTRING1 "${workspace}_" --arg SUBSTRING2 "${workspace}-" '.UserPools[] | select((.Name | contains($SUBSTRING1)) or (.Name | contains($SUBSTRING2))) | .Name')
  else
    user_pools=$(echo "$user_pools" | jq -r '.UserPools[] | .Name')
  fi

  [ -z "$user_pools" ] && echo -e "${RED}No Cognito User Pools found.${NC}" || for up in $user_pools; do
    echo -e "${GREEN}Cognito User Pool: ${up} ${NC}"
  done

  identity_pools=$(aws cognito-identity list-identity-pools --max-results 60 --output json)

  if [ -n "$workspace" ]; then
    identity_pools=$(echo "$identity_pools" | jq -r --arg SUBSTRING1 "${workspace}_" --arg SUBSTRING2 "${workspace}-" '.IdentityPools[] | select((.IdentityPoolName | contains($SUBSTRING1)) or (.IdentityPoolName | contains($SUBSTRING1))) | .IdentityPoolName')
  else
    identity_pools=$(echo "$identity_pools" | jq -r '.IdentityPools[] | .IdentityPoolName')
  fi

  [ -z "$identity_pools" ] && echo -e "${RED}No Cognito Identity Pools found.${NC}" || for ip in $identity_pools; do
    echo -e "${GREEN}Cognito Identity Pool: ${ip} ${NC}"
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

  [ -z "$buses" ] && echo -e "${RED}No EventBridge Buses found.${NC}" && return 0

  for bus in $buses; do
    echo -e "${GREEN}EventBridge Bus: ${bus} ${NC}"
  done
}

function _list_sns_subscriptions() {
  local workspace=$1
  local subs=$(aws sns list-subscriptions --output json)

  if [ -n "$workspace" ]; then
    subs=$(echo "$subs" | jq -r --arg SUBSTRING1 "${workspace}_" --arg SUBSTRING2 "${workspace}-" ' .Subscriptions[] | select((.SubscriptionArn | contains($SUBSTRING1)) or (.TopicArn | contains($SUBSTRING1)) or (.SubscriptionArn | contains($SUBSTRING2)) or (.TopicArn | contains($SUBSTRING2))) | .SubscriptionArn')
  else
    subs=$(echo "$subs" | jq -r '.Subscriptions[] | .SubscriptionArn')
  fi

  [ -z "$subs" ] && echo -e "${RED}No SNS Subscriptions found.${NC}" && return 0

  for sub in $subs; do
    echo -e "${GREEN}SNS Subscription: ${sub} ${NC}"
  done
}

function _delete_sns_subscriptions() {
  local workspace=$1
  local subs=$(aws sns list-subscriptions --output json)
  if [ -n "$workspace" ]; then
    subs=$(echo "$subs" | jq -r --arg SUBSTRING1 "${workspace}_" --arg SUBSTRING2 "${workspace}-" ' .Subscriptions[] | select((.SubscriptionArn | contains($SUBSTRING1)) or (.TopicArn | contains($SUBSTRING1)) or (.SubscriptionArn | contains($SUBSTRING2)) or (.TopicArn | contains($SUBSTRING2))) | .SubscriptionArn')

    [ -z "$subs" ] && echo -e "${RED}No SNS Subscriptions found for ${workspace} ${NC}" && return 0

    for sub in $subs; do
      echo -e "${GREEN}Deleting Subscription: ${sub} ${NC}"
      aws sns unsubscribe --subscription-arn $sub
    done
  fi
}

function _list_lambda_event_source_mappings() {
  local workspace=$1
  local mappings=$(aws lambda list-event-source-mappings --output json)

  if [ -n "$workspace" ]; then
    mappings=$(echo "$mappings" | jq -r --arg SUBSTRING1 "${workspace}_" --arg SUBSTRING2 "${workspace}-" '.EventSourceMappings[] | select((.FunctionArn | contains($SUBSTRING1)) or (.FunctionArn | contains($SUBSTRING2))) | .UUID')
  else
    mappings=$(echo "$mappings" | jq -r '.EventSourceMappings[] | .UUID')
  fi

  [ -z "$mappings" ] && echo -e "${RED}No Lambda Event Source Mappings found.${NC}" && return 0

  for mapping in $mappings; do
    echo -e "${GREEN}Lambda Event Source Mapping UUID: ${mapping} ${NC}"
  done
}

function _delete_lambda_event_source_mappings() {
  local workspace=$1
  local mappings=$(aws lambda list-event-source-mappings --output json)

  if [ -n "$workspace" ]; then
    mappings=$(echo "$mappings" | jq -r --arg SUBSTRING1 "${workspace}_" --arg SUBSTRING2 "${workspace}-" '.EventSourceMappings[] | select((.FunctionArn | contains($SUBSTRING1)) or (.FunctionArn | contains($SUBSTRING2))) | .UUID')

    [ -z "$mappings" ] && echo -e "${RED}No Lambda Event Source Mappings found.${NC}" && return 0

    for mapping in $mappings; do
      echo -e "${GREEN}Deleting Lambda Event Source Mapping UUID: ${mapping} ${NC}"
      aws lambda delete-event-source-mapping --uuid $mapping
    done
  fi
}

function _list_workspace_resources() {
  # _list_tagged_resources "$TERRAFORM_WORKSPACE"
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
  if [[ -z "${TERRAFORM_WORKSPACE:-}" ]]; then
    echo -e "${RED}❌ ERROR: TERRAFORM_WORKSPACE is not set.${NC}"
    exit 1
  fi

  case "$TERRAFORM_WORKSPACE" in
  ndr-dev | ndr-test | pre-prod | prod)
    echo -e "${RED}❌ ERROR: Deletion is not allowed for workspace: ${TERRAFORM_WORKSPACE} ${NC}"
    exit 1
    ;;
  esac

  _delete_log_groups "$TERRAFORM_WORKSPACE"
  _delete_lambda_layers "$TERRAFORM_WORKSPACE"
  _delete_lambdas "$TERRAFORM_WORKSPACE"
  _delete_iam "$TERRAFORM_WORKSPACE"
  _delete_cloudwatch_alarms "$TERRAFORM_WORKSPACE"
  _delete_sns_subscriptions "$TERRAFORM_WORKSPACE"
  _delete_cloudwatch_dashboards "$TERRAFORM_WORKSPACE"
  _delete_sns_topics "$TERRAFORM_WORKSPACE"
  _delete_ssm_parameters "$TERRAFORM_WORKSPACE"
  _delete_secrets "$TERRAFORM_WORKSPACE"
  _delete_lambda_event_source_mappings "$TERRAFORM_WORKSPACE"
  _delete_resource_groups "$TERRAFORM_WORKSPACE"
}

# Parse args
for arg in "$@"; do
  case "$arg" in
  --delete)
    do_delete=true
    shift
    ;;
  *)
    TERRAFORM_WORKSPACE="$arg"
    shift
    ;;
  esac
done

# Always list resources first
_list_workspace_resources

# If deletion was requested, ask for confirmation
if $do_delete; then
  echo
  read -r -p "Do you want to delete these resources? Type YES to confirm: " answer
  if [ "$answer" = "YES" ]; then
    _delete_workspace_resources
  else
    echo -e "${RED}Deletion cancelled.${NC}"
  fi
fi
