# Provide a reference to your default VPC
resource "aws_default_vpc" "default" {
  assign_generated_ipv6_cidr_block = true
}

data "aws_route53_zone" "selected" {
  name         = "${var.DOMAIN}."
  private_zone = false
}

resource "aws_route53_record" "webdav_domain_record" {
  allow_overwrite = true
  name            = var.SUBDOMAIN
  type            = "A"
  zone_id         = data.aws_route53_zone.selected.zone_id
  alias {
    name                   = aws_alb.webdav_alb.dns_name
    zone_id                = aws_alb.webdav_alb.zone_id
    evaluate_target_health = false
  }
  depends_on = [aws_alb.webdav_alb]
}

# Provide references to your default subnets
resource "aws_default_subnet" "default_subnets" {
  # Use your own region here, and loop through subnets defined in tf/vars.tf
  for_each          = var.subnets
  availability_zone = "${var.AWS_REGION}${each.value}" #"${var.AWS_REGION}a"
}

resource "aws_acm_certificate" "webdav_domain_cert" {
  domain_name       = var.SUBDOMAIN
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = var.DASHED_SUBDOMAIN
  }
}

resource "aws_acm_certificate_validation" "webdav_domain_cert_validation" {
  certificate_arn = aws_acm_certificate.webdav_domain_cert.arn

  validation_record_fqdns = [for record in aws_route53_record.webdav_domain_validation_record : record.fqdn]
}

resource "aws_route53_record" "webdav_domain_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.webdav_domain_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

resource "aws_alb" "webdav_alb" {
  name               = var.DASHED_SUBDOMAIN #load balancer name
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    for subnet in aws_default_subnet.default_subnets : subnet.id
  ]
  # security group
  security_groups = ["${var.load_balancer_security_group_id}"]
}

resource "aws_lb_target_group" "webdav_lb_target_group" {
  name        = var.DASHED_SUBDOMAIN
  port        = 443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default.id # default VPC

  health_check {
    matcher = "200-499"
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_alb.webdav_alb.arn #  load balancer
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.webdav_domain_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webdav_lb_target_group.arn # target group
  }

  depends_on = [aws_acm_certificate.webdav_domain_cert, aws_acm_certificate_validation.webdav_domain_cert_validation]
}
