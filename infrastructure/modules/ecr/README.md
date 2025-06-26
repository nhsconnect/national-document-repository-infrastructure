# ECR Repository Module-

## Features

- ECR repository with custom name derived from app and environment
- Lifecycle policy to clean up unused images automatically
- Cross-account access via repository policy
- Resource tagging with environment and owner
- Output of repository URL for use in pipelines or other modules

---

## Usage

```hcl
module "ecr_repository" {
  source = "./modules/ecr"

  # Required
  app_name = "my-app"

  # Required
  environment = "prod"

  # Required
  current_account_id = "123456789012"

  # Required
  owner = "platform"
}


```

<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->
