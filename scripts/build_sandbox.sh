#!/bin/bash
set -euo pipefail

required_profile="NDR-Dev-RW"

if [[ "${AWS_PROFILE:-}" != "$required_profile" ]]; then
  echo "❌ Error: AWS_PROFILE must be set to \"$required_profile\""
  echo "👉 Example: export AWS_PROFILE=$required_profile"
  exit 1
fi

branch="${WORKSPACE:-$(git rev-parse --abbrev-ref HEAD)}"
branch=$(echo "$branch" | sed 's/[^a-zA-Z0-9]//g')
branch="${branch,,}"
apply="${APPLY:-false}"

# Forbidden branches
forbidden_workspaces=("main" "prod" "pre-prod" "ndr-test" "ndr-dev" "preprod" "ndrtest" "ndrdev")

for fb in "${forbidden_workspaces[@]}"; do
  if [[ "$branch" == "$fb" ]]; then
    echo "❌ Error: Deployment of workspace '$fb' is not allowed. If you are trying to deploy main to your sandbox then provide a workspace name."
    exit 1
  fi
done

cd infrastructure/
terraform init -backend-config=backend.conf
terraform workspace select -or-create "$branch"
terraform plan -input=false -var-file=dev.tfvars -out tf.plan

if [[ "$apply" == "true" ]]; then
  terraform apply -auto-approve -input=false tf.plan
fi
