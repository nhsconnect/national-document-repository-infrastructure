resource "aws_route53_zone" "ndr_zone" {
  count = var.using_arf_hosted_zone ? 0 : 1
  name  = var.domain
  tags = {
    Name        = "${terraform.workspace}-ndr_zone"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

data "aws_route53_zone" "ndr_zone" {
  name  = var.domain
  count = var.using_arf_hosted_zone ? 1 : 0
}

resource "aws_route53_record" "ndr_fargate_record" {
  name    = terraform.workspace
  type    = "CNAME"
  records = [var.dns_name]
  zone_id = var.using_arf_hosted_zone ? data.aws_route53_zone.ndr_zone[0].zone_id : aws_route53_zone.ndr_zone[0].zone_id
  ttl     = 300
}
