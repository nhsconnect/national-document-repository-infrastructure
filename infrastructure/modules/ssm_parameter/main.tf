resource "aws_ssm_parameter" "secret" {
  count       = var.ignore_value_changes ? 0 : 1
  name        = "/ndr/${terraform.workspace}/${var.name}"
  type        = var.type
  description = var.description
  value       = var.value
  key_id      = var.key_id
  depends_on  = [var.resource_depends_on]
  tags = {
    Name = "${terraform.workspace}-ssm"
  }

}


resource "aws_ssm_parameter" "secret_ignore_value_changes" {
  count       = var.ignore_value_changes ? 1 : 0
  name        = "/ndr/${terraform.workspace}/${var.name}"
  type        = var.type
  description = var.description
  value       = var.value
  key_id      = var.key_id
  depends_on  = [var.resource_depends_on]
  tags = {
    Name = "${terraform.workspace}-ssm"
  }

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

