locals {
  lambda_layers = contains(var.non_persistent_workspaces, terraform.workspace) ? var.default_lambda_layers : concat(var.default_lambda_layers, var.extra_lambda_layers)
}
