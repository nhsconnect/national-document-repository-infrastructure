#!/bin/bash

set -euo pipefail

# Check for required argument
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <workspace> <vars file>"
  echo "Example: $0 ndrd dev.tfvars"
  exit 1
fi

WORKSPACE="$1"
TFVARS="$2"
REGION="eu-west-2"

# Define suffixes and their corresponding Terraform resource paths
declare -A LAYER_SUFFIX_TO_TF_RESOURCE
LAYER_SUFFIX_TO_TF_RESOURCE=(
  ["core"]="module.lambda-layer-core.aws_lambda_layer_version.lambda_layer"
  ["data"]="module.lambda-layer-data.aws_lambda_layer_version.lambda_layer"
  ["reports"]="module.lambda-layer-reports.aws_lambda_layer_version.lambda_layer"
  ["alerting"]="module.lambda-layer-alerting.aws_lambda_layer_version.lambda_layer"
)

for SUFFIX in "${!LAYER_SUFFIX_TO_TF_RESOURCE[@]}"; do
  LAYER_NAME="${WORKSPACE}_${SUFFIX}_lambda_layer"
  TF_RESOURCE="${LAYER_SUFFIX_TO_TF_RESOURCE[$SUFFIX]}"

  echo "🔍 Processing $LAYER_NAME → $TF_RESOURCE"

  # Get the latest version ARN for the layer
  LAYER_ARN=$(aws lambda list-layer-versions \
    --layer-name "$LAYER_NAME" \
    --region "$REGION" \
    --query 'LayerVersions[0].LayerVersionArn' \
    --output text)

  if [[ "$LAYER_ARN" == "None" || -z "$LAYER_ARN" ]]; then
    echo "❌ No versions found for $LAYER_NAME — skipping"
    continue
  fi

  echo "✅ Found latest version: $LAYER_ARN"

  # Check if already imported
  if terraform state list 2>/dev/null | grep -q "$TF_RESOURCE"; then
    echo "ℹ️  Already imported: $TF_RESOURCE"
  else
    echo "📦 Importing..."
    cd ../infrastructure/
    terraform import -config=. -var-file="$TFVARS" "$TF_RESOURCE" "$LAYER_ARN"
  fi

  echo "--------------------------------------------"
done
