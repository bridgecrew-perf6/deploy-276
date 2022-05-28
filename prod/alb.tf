data "aws_iam_policy_document" "allow_access_alb_accesslogs" {
	statement {
		sid = "AWSConsoleStmt"
		effect = "Allow"
		principals {
		  type = "AWS"
		  identifiers = ["arn:aws:iam::600734575887:root"]
		}
		actions = [
			"s3:PutObject"
		]

		resources = [
			"arn:aws:s3:::${var.s3_bucket_alb_logging}/AWSLogs/${var.aws_account_id}/*",
		]
	}
  statement {
	sid = "AWSLogDeliveryWrite"
	effect = "Allow"
    actions   = ["s3:PutObject"]
	resources = ["arn:aws:s3:::${var.s3_bucket_alb_logging}/AWSLogs/${var.aws_account_id}/*",]
    condition {
      test = "StringEquals"
      values = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

  statement {
	sid ="AWSLogDeliveryAclCheck"
	effect = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${var.s3_bucket_alb_logging}"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

}

resource "aws_s3_bucket" "alb-access-logs" {
  bucket = var.s3_bucket_alb_logging
}

resource "aws_s3_bucket_policy" "alb-access-logs" {
	bucket = var.s3_bucket_alb_logging
	policy = data.aws_iam_policy_document.allow_access_alb_accesslogs.json
}

resource "aws_security_group" "alb-inbound" {
  name        = "alb-inbound"
  description = "ALB inbound traffic"
  vpc_id = aws_default_vpc.default.id

	ingress {
		description = "Ingress HTTP"
		from_port = 0
		to_port = "80"
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = ["::/0"]
	}

	ingress {
		description = "Ingress HTTPS"
		from_port = 0
		to_port = "443"
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = ["::/0"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = ["::/0"]
	}
}

module "alb" {
	source = "terraform-aws-modules/alb/aws"
	version = "~> 6.0"

	name = "default"

	load_balancer_type = "application"

	vpc_id = aws_default_vpc.default.id
	subnets = [aws_subnet.public1.id, aws_subnet.public2.id]
	security_groups = [
		aws_security_group.alb-inbound.id
	]
	access_logs = {
		bucket = aws_s3_bucket.alb-access-logs.bucket
		enabled = true # TODO
	}

	http_tcp_listeners = [
		{
			port = 80
			protocol = "HTTP"
			target_group_idx = 0
			action_type = "redirect"
			redirect = {
				port = "443"
				protocol = "HTTPS"
				status_code = "HTTP_301"
			}
		}
	]

	https_listeners = [
		{
			port = 443
			protocol = "HTTPS"
			certificate_arn = aws_acm_certificate.cert.arn
			target_group_idx = 0
		}
	]

	https_listener_rules = [
		{
			https_listener_index = 0
			priority = 100

			actions = [{
				type = "forward"
				target_group_index = 1
			}]

			conditions = [{
				path_patterns = ["/api/*"]
				host_headers = ["hidiscuss.ga"]
			}]
		},
		{
			https_listener_index = 0
			priority = 101
			actions = [{
				type = "forward"
				target_group_index = 2
			}]
			conditions =[{
				host_headers = ["hidiscuss.ga"]
				path_patterns = ["/socket/*"]
			}]
		},
		{
			https_listener_index = 0
			priority = 200
			actions = [{
				type = "forward"
				target_group_index = 0
			}]
			conditions =[{
				host_headers = ["hidiscuss.ga"]
			}]
		}
	]

	target_groups = [
		{
			name_prefix = "fe-"
			backend_protocol = "HTTP"
			backend_port     = 3000 
			target_type = "ip"
		},
		{
			name_prefix = "be-s-"
			backend_protocol = "HTTP"
			backend_port = 8080
			target_type = "ip"
			health_check = {
				port = 8080
				protocol = "HTTP"
				path = "/login"
				interval = 240
				timeout = 120
				healthy_threshold = 3
				unhealthy_threshold = 3
			}
		},
		{
			name_prefix = "be-ws-"
			backend_protocol = "HTTP"
			backend_port = 3001
			target_type = "ip"
			health_check = {
				port = 3001
				protocol = "HTTP"
				path = "/socket/"
				matcher = "200,201,426"
			}
		}
	]

	depends_on = [
	  aws_s3_bucket.alb-access-logs
	]
}