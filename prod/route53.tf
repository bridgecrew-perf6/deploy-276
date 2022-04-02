resource "aws_route53_zone" "default" {
	name = "${var.domain}"
	comment = "Signal CapStone Project"
	force_destroy = false
}

resource "aws_route53_record" "cert" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.default.zone_id
}

resource "aws_route53_record" "elb" {
  name = "${var.domain}"
  type = "A"
  alias {
    name = module.alb.lb_dns_name
    zone_id = module.alb.lb_zone_id
    evaluate_target_health = true
  }

  zone_id = aws_route53_zone.default.zone_id  
}