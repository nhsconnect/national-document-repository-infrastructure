default: help

help: ## This help message
		@grep -E --no-filename '^[a-zA-Z-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-42s\033[0m %s\n", $$1, $$2}'

.PHONY: Install
install: ## Run NPM install 
	cd ./infrastructure && npm install

# Formatting
.PHONY:format-all
format-all: ## Format all terraform 
	terraform fmt -recursive .

# Documentation
.PHONY:generate-terraform-docs
generate-terraform-docs: ## Generate terraform documentation 
	./scripts/create-terraform-docs.sh

# Installing
.PHONY:build-sandbox
build-sandbox: ## Build a sandbox using either the branch as the workspace name or pass in a name for the workspace e.g. make build-sandbox WORKSPACE=my-workspace
	WORKSPACE=$(WORKSPACE) APPLY=$(APPLY) ./scripts/build_sandbox.sh

# Linting

# Testing

# Bootstrap
.PHONY: init-bootstrap
init-bootstrap: ## Run Bootstrap terraform
	cd ./bootstrap && terraform init

.PHONY: apply-bootstrap
apply-bootstrap: ## Apply Bootstrap terraform
	cd ./bootstrap && terraform apply


