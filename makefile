default: help

.PHONY: Install
install:
	cd ./infrastructure && npm install

# Pre-commit husky
.PHONY:pre-commit
pre-commit:  generate-terraform-docs format-all

# Pre-push husky
# .PHONY:pre-push
# pre-commit: 

# Formatting
.PHONY:format-all
format-all:
	terraform fmt -recursive .

# Documentation
.PHONY:generate-terraform-docs
generate-terraform-docs:
	./scripts/create-terraform-docs.sh

# Installing

# Linting

# Testing

# Bootstrap
.PHONY: init-bootstrap
init-bootstrap:
	cd ./bootstrap && terraform init

.PHONY: apply-bootstrap
apply-bootstrap:
	cd ./bootstrap && terraform apply


# Rotate the JWT signing key that we store in AWS secret manager
# This assume that the secret is already created by terraform.
.PHONY: rotate-key
rotate-key:
ifdef env
	ssh-keygen -t rsa -b 4096 -m PEM -f $(env)_jwt_signing_key.rsa -q -N ""
	-aws secretsmanager update-secret --secret-id $(env)_jwt_signing_key --secret-string file://$(env)_jwt_signing_key.rsa
	-aws secretsmanager update-secret --secret-id $(env)_jwt_signing_key_pub --secret-string file://$(env)_jwt_signing_key.rsa.pub
	rm $(env)_jwt_signing_key.rsa $(env)_jwt_signing_key.rsa.pub
else
	@echo 'Please provide the env to rotate_key. Example:  make rotate_key env=ndra'
endif