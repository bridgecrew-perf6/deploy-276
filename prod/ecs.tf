resource "aws_ecs_cluster" "default" {
  name = "service-ecs-cluster"

  setting {
	name ="containerInsights"
	value = "enabled"
  }
}


resource "aws_security_group" "ecs-service-default" {
  name        = "ecs-service-default"
  description = "ECS Service Default"
  vpc_id = aws_default_vpc.default.id

	ingress {
		description = "From VPC Endpoint"
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["172.31.0.0/16"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = ["::/0"]
	}
}