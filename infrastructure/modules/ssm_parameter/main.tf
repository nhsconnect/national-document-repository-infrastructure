resource "aws_ssm_parameter" "secret" {
  name        = "/ndr/${terraform.workspace}/${var.name}"
  type        = var.type
  description = var.description
  value       = var.value
  depends_on  = [var.resource_depends_on]
  tags = {
    Name = "${terraform.workspace}-ssm"
  }
}

