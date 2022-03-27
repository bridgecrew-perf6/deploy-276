resource "aws_ecs_cluster" "default" {
  name = "service-ecs-cluster"
}


resource "aws_security_group" "ecs-service-default" {
  name        = "ecs-service-default"
  description = "ECS Service Default"
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
		description = "Ingress HTTP"
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