resource "aws_lb" "ecs_lb" {
  count                      = var.is_lb_needed ? 1 : 0
  name                       = "${terraform.workspace}-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.ndr_ecs_sg.id]
  subnets                    = [for subnet in var.public_subnets : subnet]
  enable_deletion_protection = local.is_production
  drop_invalid_header_fields = true

  access_logs {
    bucket  = var.logs_bucket
    enabled = true
  }

  tags = {
    Name = "${terraform.workspace}-lb-${var.ecs_cluster_name}"
  }
}

resource "aws_lb_target_group" "ecs_lb_tg" {
  count = var.is_lb_needed ? 1 : 0

  name        = "${terraform.workspace}-ecs"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = "200"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  tags = {
    Name = "lb_target_group-${var.ecs_cluster_name}"
  }
}

resource "aws_lb_listener" "https" {
  count             = var.is_lb_needed ? 1 : 0
  load_balancer_arn = aws_lb.ecs_lb[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.amazon_issued[0].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_lb_tg[0].arn
  }
}

data "aws_acm_certificate" "amazon_issued" {
  count = var.is_lb_needed ? 1 : 0

  domain      = var.certificate_domain
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

resource "aws_lb_listener" "http" {
  count = var.is_lb_needed ? 1 : 0

  load_balancer_arn = aws_lb.ecs_lb[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.ecs_lb_tg[0].arn
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
