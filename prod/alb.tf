data "aws_iam_policy_document" "allow_access_alb_accesslogs" {
	statement {
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
	subnets = [aws_subnet.public.id, aws_subnet.public.id]
	security_groups = [
		aws_security_group.alb-inbound.id
	]
	access_logs = {
		bucket = aws_s3_bucket.alb-access-logs.bucket
	}

	http_tcp_listeners = [
		{
			port = 80
			protocol = "HTTP"
			target_group_idx = 0
		}
	]

	target_groups = [
		{
		name_prefix      = "pref-"
		backend_protocol = "HTTP"
		backend_port     = 80 
		target_type = "ip"
		}
	]

	depends_on = [
	  aws_s3_bucket.alb-access-logs
	]
}