#!/bin/bash
set -euo pipefail

branch="${WORKSPACE:-$(git rev-parse --abbrev-ref HEAD)}"
branch=$(echo "$branch" | sed 's/[^a-zA-Z0-9]//g')
branch="${branch,,}"
apply="${APPLY:-false}"

# Forbidden branches
forbidden_branches=("main" "prod" "pre-prod" "ndr-test" "ndr-dev")

for fb in "${forbidden_branches[@]}"; do
  if [[ "$branch" == "$fb" ]]; then
    echo "❌ Error: Deployment from branch '$branch' is not allowed."
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
